package com.espe.parqueaderos.parqueadero.service.impl;

import com.espe.parqueaderos.parqueadero.entity.Espacio;
import com.espe.parqueaderos.parqueadero.entity.HistorialOcupacion;
import com.espe.parqueaderos.parqueadero.repository.EspacioRepository;
import com.espe.parqueaderos.parqueadero.repository.HistorialOcupacionRepository;
import com.espe.parqueaderos.parqueadero.repository.ReservaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class EspacioService {
    @Autowired
    private EspacioRepository espacioRepository;

    @Autowired
    private HistorialOcupacionRepository historialRepository;

    @Autowired
    private ReservaRepository reservaRepository;

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @Transactional //Asegurando patrones ACID
    public Espacio actualizarEstadoDesdeCamara(String identificador, Long parqueaderoId, String nuevoEstado, BigDecimal confianzaIA){

        //buscar espacio
        Espacio espacio = espacioRepository.findByIdentificadorAndParqueaderoId(identificador, parqueaderoId)
                .orElseThrow(() -> new RuntimeException("Espacio " + identificador + " no encontrado en parqueadero " + parqueaderoId));

        if (espacio.getEstado().equalsIgnoreCase(nuevoEstado)){
            return espacio;
        }

        if("OCUPADO".equals(nuevoEstado)){
            validarOcupacion(espacio);
        }

        //actualizar estado
        espacio.setEstado(nuevoEstado);
        Espacio espacioGuardado = espacioRepository.save(espacio);

        HistorialOcupacion historial = new HistorialOcupacion();
        historial.setEspacio(espacioGuardado);
        historial.setEstadoDetectado(nuevoEstado);
        historial.setConfianzaIa(confianzaIA);
        historialRepository.save(historial);

        messagingTemplate.convertAndSend("/topic/espacios", espacioGuardado);

        return espacioGuardado;
    }

    public void validarOcupacion(Espacio espacio){
        LocalDateTime ahora = LocalDateTime.now();

        boolean tieneReservaActiva = reservaRepository.existeConflictoDeHorario(
                espacio.getId(),
                ahora.minusMinutes(5),
                ahora.plusMinutes(5)
        );

        if(tieneReservaActiva){
            System.out.println("El usuario con reserva llegó" + espacio.getIdentificador());
        } else {
            System.out.println("El espacio " + espacio.getIdentificador() + " fue ocupado");
        }
    }

    public List<Espacio> obtenerTodos(Long parqueaderoId){
        return espacioRepository.findAll();
    }

    public List<Espacio> obtenerEspaciosLibres(Long parqueaderosId){
        return espacioRepository.findByParqueaderoIdAndEstado(parqueaderosId, "LIBRE");
    }

    public Espacio cambiarEstado(Long espacioId, String nuevoEstado) {
        Espacio espacio = espacioRepository.findById(espacioId)
                .orElseThrow(() -> new RuntimeException("Espacio no encontrado"));

        espacio.setEstado(nuevoEstado);
        Espacio espacioGuardado = espacioRepository.save(espacio);

        messagingTemplate.convertAndSend("/topic/", espacioGuardado);
        return espacioGuardado;
    }
}
