package com.espe.parqueaderos.parqueadero.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**") //todas las rutas
                .allowedOriginPatterns("*") // cualquier origen
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS") // Todos las operaciones
                .allowedHeaders("*") // Todos los headers
                .allowCredentials(true); // Permite cookies/tokens
    }
}