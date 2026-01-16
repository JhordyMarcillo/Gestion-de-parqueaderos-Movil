package com.espe.parqueaderos.parqueadero.dto.response;

import lombok.Data;

@Data
public class JwtResponse {
    private String token;
    private String type = "Bearer";
    private Long id;
    private String email;
    private String rol;

    public JwtResponse(String token, Long id, String email, String rol) {
        this.token = token;
        this.id = id;
        this.email = email;
        this.rol = rol;
        this.type = "Bearer";
    }
}
