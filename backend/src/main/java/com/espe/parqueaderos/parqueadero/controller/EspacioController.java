package com.espe.parqueaderos.parqueadero.controller;

import com.espe.parqueaderos.parqueadero.entity.Espacio;
import com.espe.parqueaderos.parqueadero.repository.EspacioRepository;
import com.espe.parqueaderos.parqueadero.service.impl.EspacioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestParam;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/parqueaderos")
@Tag(name = "Espacios y Sensores", description = "Gestión de sensores IoT y consulta de espacios")
public class EspacioController {

    @Autowired
    private EspacioService espacioService;


    @GetMapping("/libres/{parqueaderoId}")
    @Operation(summary = "Listar espacios libres", description = "Usado por la App para mostrar dónde parquear")
    public ResponseEntity<List<Espacio>> obtenerLibres(@PathVariable Long parqueaderoId) {
        return ResponseEntity.ok(espacioService.obtenerEspaciosLibres(parqueaderoId));
    }

    @GetMapping("/todos/{parqueaderoId}")
    @Operation(summary = "Mapa completo", description = "Muestra todos los espacios (ocupados y libres)")
    public ResponseEntity<List<Espacio>> obtenerTodos(@PathVariable Long parqueaderoId) {
        return ResponseEntity.ok(espacioService.obtenerTodos(parqueaderoId));
    }


    @PostMapping("/detectar")
    @Operation(summary = "Simulación Cámara", description = "Actualiza el estado de un espacio basado en detección visual")
    public ResponseEntity<?> recibirDeteccion(
            @RequestParam String identificador,
            @RequestParam Long parqueaderoId,
            @RequestParam String estado,
            @RequestParam(defaultValue = "0.99") BigDecimal confianza
    ) {
        Espacio actualizado = espacioService.actualizarEstadoDesdeCamara(identificador, parqueaderoId, estado, confianza);
        return ResponseEntity.ok(actualizado);
    }

    @PutMapping("/{id}/estado")
    @Operation(summary = "Cambiar estado manual", description = "Permite al Admin forzar el estado de un espacio")
    public ResponseEntity<?> actualizarEstado(
            @PathVariable Long id,
            @RequestParam String estado) {

        Espacio espacioActualizado = espacioService.cambiarEstado(id, estado.toUpperCase());

        return ResponseEntity.ok(espacioActualizado);
    }
}