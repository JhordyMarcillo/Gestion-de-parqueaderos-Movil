package com.espe.parqueaderos.parqueadero.dto.request;

import lombok.Data;

@Data
public class LoginRequest {
    private String email;
    private String password;
}
