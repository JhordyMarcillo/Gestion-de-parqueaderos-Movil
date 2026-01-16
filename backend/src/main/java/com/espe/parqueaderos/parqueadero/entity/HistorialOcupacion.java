package com.espe.parqueaderos.parqueadero.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "historial_ocupacion")
@Data
public class HistorialOcupacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "espacio_id", nullable = false)
    private Espacio espacio;

    @Column(name = "estado_detectado", nullable = false)
    private String estadoDetectado;

    @CreationTimestamp
    @Column(name = "fecha_evento", updatable = false)
    private LocalDateTime fechaEvento;

    @Column(name = "confianza_ia")
    private BigDecimal confianzaIa;
}