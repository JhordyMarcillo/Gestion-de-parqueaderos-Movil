package com.espe.parqueaderos.parqueadero.controller;

import com.espe.parqueaderos.parqueadero.dto.request.CrearReservaRequest;
import com.espe.parqueaderos.parqueadero.dto.request.ReservaRequest;
import com.espe.parqueaderos.parqueadero.entity.Espacio;
import com.espe.parqueaderos.parqueadero.entity.Reserva;
import com.espe.parqueaderos.parqueadero.entity.Usuario;
import com.espe.parqueaderos.parqueadero.repository.EspacioRepository;
import com.espe.parqueaderos.parqueadero.repository.ReservaRepository;
import com.espe.parqueaderos.parqueadero.repository.UsuarioRepository;
import com.espe.parqueaderos.parqueadero.service.impl.ReservaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;

@RestController
@RequestMapping("/api/reservas")
@Tag(name = "Gestión de Reservas", description = "Creación y consulta de reservas")
@SecurityRequirement(name = "Bearer Authentication")
public class ReservaController {

    @Autowired
    private ReservaService reservaService;

    @Autowired
    private ReservaRepository reservaRepository;

    @Autowired
    private EspacioRepository espacioRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @PostMapping("/crear")
    public ResponseEntity<?> crearReserva(@RequestBody ReservaRequest request) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String qrCodeString = UUID.randomUUID().toString();
        String email = auth.getName();

        if (reservaRepository.existeReservaActiva(email)) {
            return ResponseEntity.status(409).body("Ya tienes una reserva");
        }

        Usuario usuario = usuarioRepository.findByEmail(email).orElseThrow();

        Espacio espacio = espacioRepository.findById(request.getEspacioId())
                .orElseThrow(() -> new RuntimeException("Espacio no encontrado"));

        if (!"LIBRE".equalsIgnoreCase(espacio.getEstado())) {
            return ResponseEntity.badRequest().body("El espacio no está disponible");
        }

        Reserva reserva = new Reserva();
        reserva.setUsuario(usuario);
        reserva.setEspacio(espacio);
        reserva.setFechaInicio(LocalDateTime.now());
        reserva.setFechaFin(LocalDateTime.now().plusHours(request.getHoras()));
        reserva.setEstado("PENDIENTE");
        reserva.setCodigoQr(qrCodeString);
        reservaRepository.save(reserva);

        espacio.setEstado("RESERVADO");
        espacioRepository.save(espacio);

        Map<String, Object> response = new HashMap<>();
        response.put("mensaje", "Reserva creada con éxito");
        response.put("id", reserva.getId());
        response.put("qr", qrCodeString);

        return ResponseEntity.ok(response);
    }

    @GetMapping("/mis-reservas")
    @Operation(summary = "Historial personal", description = "Lista las reservas del usuario logueado")
    public ResponseEntity<List<Reserva>> misReservas(Authentication authentication) {
        String emailUsuario = authentication.getName();
        return ResponseEntity.ok(reservaService.listarMisReservas(emailUsuario));
    }

    @PutMapping("/cancelar/{id}")
    public ResponseEntity<?> cancelarReserva(@PathVariable Long id) {
        Reserva reserva = reservaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Reserva no encontrada"));

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

        reserva.setEstado("CANCELADA");
        reservaRepository.save(reserva);

        Espacio espacio = reserva.getEspacio();
        espacio.setEstado("LIBRE");
        espacioRepository.save(espacio);

        return ResponseEntity.ok("Reserva cancelada");
    }
}