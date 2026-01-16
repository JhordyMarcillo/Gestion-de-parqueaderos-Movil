package com.espe.parqueaderos.parqueadero.dto.request;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class CrearReservaRequest {
    private Long usuarioId;
    private Long espacioId;
    private LocalDateTime fechaInicio;
    private LocalDateTime fechaFin;
}
