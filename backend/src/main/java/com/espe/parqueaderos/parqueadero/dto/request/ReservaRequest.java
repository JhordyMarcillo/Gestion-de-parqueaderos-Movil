package com.espe.parqueaderos.parqueadero.dto.request;

import lombok.Data;

@Data
public class ReservaRequest {
    private Long espacioId;
    private int horas;
}