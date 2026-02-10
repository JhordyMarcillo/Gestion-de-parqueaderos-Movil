package com.espe.parqueaderos.parqueadero.controller;

import com.espe.parqueaderos.parqueadero.entity.HistorialOcupacion;
import com.espe.parqueaderos.parqueadero.repository.HistorialOcupacionRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/reportes")
@Tag(name = "Reportes y Auditoría", description = "Datos para el panel administrativo")
@SecurityRequirement(name = "Bearer Authentication")
public class ReporteController {

    @Autowired
    private HistorialOcupacionRepository historialRepository;

    @GetMapping("/ocupacion")
    @PreAuthorize("hasRole('ADMIN')") //Admin
    @Operation(summary = "Historial de sensores", description = "Auditoría de todos los cambios detectados por las cámaras")
    public ResponseEntity<Page<HistorialOcupacion>> obtenerHistorial(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        Page<HistorialOcupacion> historial = historialRepository.findAll(
                PageRequest.of(page, size, Sort.by("fechaEvento").descending())
        );
        return ResponseEntity.ok(historial);
    }
}