package com.espe.parqueaderos.parqueadero.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class EspacioEstadoResponse {
    private Long id;
    private String identificacion;
    private String estado;
    private Boolean esPreferencial;
}
