package com.espe.parqueaderos.parqueadero.service.impl;

import com.espe.parqueaderos.parqueadero.dto.request.CrearReservaRequest;
import com.espe.parqueaderos.parqueadero.entity.Espacio;
import com.espe.parqueaderos.parqueadero.entity.Parqueadero;
import com.espe.parqueaderos.parqueadero.entity.Reserva;
import com.espe.parqueaderos.parqueadero.entity.Usuario;
import com.espe.parqueaderos.parqueadero.repository.EspacioRepository;
import com.espe.parqueaderos.parqueadero.repository.ReservaRepository;
import com.espe.parqueaderos.parqueadero.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Duration;
import java.util.List;

@Service
public class ReservaService {

    @Autowired
    private ReservaRepository reservaRepository;

    @Autowired
    private EspacioRepository espacioRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Transactional
    public Reserva crearReserva(CrearReservaRequest request, String emailUsuarioAutenticado) {
        Usuario usuario = usuarioRepository.findByEmail(emailUsuarioAutenticado)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        Espacio espacio = espacioRepository.findById(request.getEspacioId())
                .orElseThrow(() -> new RuntimeException("Espacio no encontrado"));

        boolean ocupado = reservaRepository.existeConflictoDeHorario(
                espacio.getId(),
                request.getFechaInicio(),
                request.getFechaFin()
        );

        if (ocupado) {
            throw new RuntimeException("El espacio no está disponible en el horario seleccionado.");
        }

        BigDecimal costoTotal = calcularCosto(espacio.getParqueadero(), request.getFechaInicio(), request.getFechaFin());

        Reserva reserva = new Reserva();
        reserva.setUsuario(usuario);
        reserva.setEspacio(espacio);
        reserva.setFechaInicio(request.getFechaInicio());
        reserva.setFechaFin(request.getFechaFin());
        reserva.setEstado("PENDIENTE");
        reserva.setMontoTotal(costoTotal);
        reserva.setCodigoQr("RES-" + System.currentTimeMillis() + "-" + usuario.getId());

        return reservaRepository.save(reserva);
    }

    private BigDecimal calcularCosto(Parqueadero parqueadero, java.time.LocalDateTime inicio, java.time.LocalDateTime fin) {
        long minutos = Duration.between(inicio, fin).toMinutes();
        double horas = minutos / 60.0;
        if (horas < 1) horas = 1;

        return parqueadero.getTarifaHora().multiply(new BigDecimal(horas));
    }

    public List<Reserva> listarMisReservas(String email) {
        Usuario usuario = usuarioRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        return reservaRepository.findByUsuarioId(usuario.getId());
    }
}