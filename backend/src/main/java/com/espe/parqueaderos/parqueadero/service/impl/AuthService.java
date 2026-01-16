package com.espe.parqueaderos.parqueadero.service.impl;


import com.espe.parqueaderos.parqueadero.dto.request.LoginRequest;
import com.espe.parqueaderos.parqueadero.dto.request.RegistroRequest;
import com.espe.parqueaderos.parqueadero.dto.response.JwtResponse;
import com.espe.parqueaderos.parqueadero.entity.Usuario;
import com.espe.parqueaderos.parqueadero.repository.UsuarioRepository;
import com.espe.parqueaderos.parqueadero.security.jwt.JwtUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.token.TokenService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtUtils jwtUtils;

    public Usuario registrarUsuario(RegistroRequest request){
        if(usuarioRepository.existsByEmail(request.getEmail())){
            throw new UsernameNotFoundException("Usuario no encontrado");
        }

        Usuario usuario = new Usuario();
        usuario.setNombreCompleto(request.getNombreCompleto());
        usuario.setEmail(request.getEmail());

        usuario.setPassword(passwordEncoder.encode(request.getPassword()));
        usuario.setRol("CLIENTE");

        return usuarioRepository.save(usuario);
    }

    public JwtResponse iniciarSesion(LoginRequest request){
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );

        SecurityContextHolder.getContext().setAuthentication(authentication);
        String jwt = jwtUtils.generateJwtToken(authentication);

        Usuario usuario = usuarioRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado"));

        return new JwtResponse(
                jwt,
                usuario.getId(),
                usuario.getEmail(),
                usuario.getRol()
        );
    }
}
