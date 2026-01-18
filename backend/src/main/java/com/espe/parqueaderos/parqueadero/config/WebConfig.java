package com.espe.parqueaderos.parqueadero.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**") // Aplica a TODAS las rutas
                .allowedOriginPatterns("*") // Permite CUALQUIER origen (celular, web, postman)
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS") // Todos los verbos
                .allowedHeaders("*") // Todos los headers
                .allowCredentials(true); // Permite cookies/tokens
    }
}