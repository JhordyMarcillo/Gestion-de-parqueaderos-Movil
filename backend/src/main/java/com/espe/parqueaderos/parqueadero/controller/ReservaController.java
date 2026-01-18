package com.espe.parqueaderos.parqueadero.controller;

import com.espe.parqueaderos.parqueadero.dto.request.CrearReservaRequest;
import com.espe.parqueaderos.parqueadero.entity.Reserva;
import com.espe.parqueaderos.parqueadero.service.impl.ReservaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reservas")
@Tag(name = "Gestión de Reservas", description = "Creación y consulta de reservas")
@SecurityRequirement(name = "Bearer Authentication")
public class ReservaController {

    @Autowired
    private ReservaService reservaService;

    @PostMapping
    @Operation(summary = "Crear nueva reserva", description = "Valida conflictos de horario y genera reserva")
    public ResponseEntity<?> crearReserva(@RequestBody CrearReservaRequest request, Authentication authentication) {
        String emailUsuario = authentication.getName();

        try {
            Reserva nuevaReserva = reservaService.crearReserva(request, emailUsuario);
            return ResponseEntity.ok(nuevaReserva);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @GetMapping("/mis-reservas")
    @Operation(summary = "Historial personal", description = "Lista las reservas del usuario logueado")
    public ResponseEntity<List<Reserva>> misReservas(Authentication authentication) {
        String emailUsuario = authentication.getName();
        return ResponseEntity.ok(reservaService.listarMisReservas(emailUsuario));
    }
}