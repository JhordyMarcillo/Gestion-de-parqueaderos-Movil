package com.espe.parqueaderos.parqueadero.dto.request;

import lombok.Data;

@Data
public class RegistroRequest {
    private String nombreCompleto;
    private String email;
    private String password;
}
