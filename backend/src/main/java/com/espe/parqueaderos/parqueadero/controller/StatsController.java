package com.espe.parqueaderos.parqueadero.controller;

import com.espe.parqueaderos.parqueadero.entity.Reserva;
import com.espe.parqueaderos.parqueadero.repository.EspacioRepository;
import com.espe.parqueaderos.parqueadero.repository.ReservaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/stats")
public class StatsController {

    @Autowired
    private EspacioRepository espacioRepository;

    @Autowired
    private ReservaRepository reservaRepository;

    @GetMapping("/dashboard")
    public ResponseEntity<?> obtenerEstadisticas() {
        long libres = espacioRepository.countByEstado("LIBRE");
        long ocupados = espacioRepository.countByEstado("OCUPADO");
        long reservados = espacioRepository.countByEstado("RESERVADO");
        long mantenimiento = espacioRepository.countByEstado("MANTENIMIENTO");

        LocalDateTime inicioDia = LocalDate.now().atStartOfDay();

        List<Reserva> reservasHoy = reservaRepository.findAll();


        Map<String, Object> stats = new HashMap<>();
        stats.put("libres", libres);
        stats.put("ocupados", ocupados);
        stats.put("reservados", reservados);
        stats.put("mantenimiento", mantenimiento);
        stats.put("totalReservasHoy", reservasHoy.stream().filter(r -> r.getFechaInicio().isAfter(inicioDia)).count());

        return ResponseEntity.ok(stats);
    }
}