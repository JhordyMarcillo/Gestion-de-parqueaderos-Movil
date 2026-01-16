package com.espe.parqueaderos.parqueadero.repository;

import com.espe.parqueaderos.parqueadero.entity.Espacio;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EspacioRepository extends JpaRepository<Espacio, Long> {
    List<Espacio> findByParqueaderoIdAndEstado(Long parqueaderoId, String estado);
    long countByParqueaderoIdAndEstado(Long parqueaderoId, String estado);
    Optional<Espacio> findByIdentificadorAndParqueaderoId(String identificador, Long parqueaderoId);
    Optional<Espacio> findById(Long parqueaderoId);
}
