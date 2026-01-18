package com.espe.parqueaderos.parqueadero.controller;
import com.espe.parqueaderos.parqueadero.dto.request.LoginRequest;
import com.espe.parqueaderos.parqueadero.dto.request.RegistroRequest;
import com.espe.parqueaderos.parqueadero.dto.response.JwtResponse;
import com.espe.parqueaderos.parqueadero.service.impl.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/login")
    @Operation(summary = "Iniciar Sesión", description = "Devuelve un token JWT si las credenciales son correctas")
    public ResponseEntity<JwtResponse> authenticateUser(@Valid @RequestBody LoginRequest loginRequest) {
        JwtResponse response = authService.iniciarSesion(loginRequest);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/register")
    @Operation(summary = "Registrar Usuario", description = "Crea una nueva cuenta de cliente")
    public ResponseEntity<?> registerUser(@Valid @RequestBody RegistroRequest signUpRequest) {
        return ResponseEntity.ok(authService.registrarUsuario(signUpRequest));
    }
}