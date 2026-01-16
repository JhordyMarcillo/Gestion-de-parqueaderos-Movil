package com.espe.parqueaderos.parqueadero.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.math.BigDecimal;

@Entity
@Table(name = "parqueaderos")
@Data
public class Parqueadero {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String nombre;

    @Column(nullable = false)
    private String direccion;

    private Double latitud;
    private Double longitud;

    @Column(nullable = false, name = "tarifa_hora")
    private BigDecimal tarifaHora;

    private Boolean activo = true;
}
