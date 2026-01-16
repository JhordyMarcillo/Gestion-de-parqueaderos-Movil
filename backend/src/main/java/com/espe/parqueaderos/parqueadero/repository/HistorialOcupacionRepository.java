package com.espe.parqueaderos.parqueadero.repository;

import com.espe.parqueaderos.parqueadero.entity.HistorialOcupacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface HistorialOcupacionRepository extends JpaRepository<HistorialOcupacion, Long> {
}
