package com.espe.parqueaderos.parqueadero.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "espacios", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"parqueadero_id", "identificador"})
})
@Data
public class Espacio {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "parqueadero_id", nullable = false)
    private Parqueadero parqueadero;

    @Column(nullable = false)
    private String identificador;

    @Column(nullable = false)
    private String estado;

    @Column(name = "es_preferencial")
    private Boolean esPreferencial = false;
}


//para presentar traer una maqueta chiquita
//parte de la aplicaicón del usuario y del administrador
