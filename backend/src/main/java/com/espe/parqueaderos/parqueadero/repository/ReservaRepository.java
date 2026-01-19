package com.espe.parqueaderos.parqueadero.repository;

import com.espe.parqueaderos.parqueadero.entity.Reserva;
import com.espe.parqueaderos.parqueadero.entity.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface ReservaRepository extends JpaRepository<Reserva, Long> {
    List<Reserva> findByUsuarioId(Long usuarioId);

    @Query("SELECT r FROM Reserva r WHERE r.espacio.id = :espacioId AND r.estado = 'PENDIENTE'")
    Optional<Reserva> findReservaPendienteByEspacio(Long espacioId);

    @Query("SELECT COUNT(r) > 0 FROM Reserva r WHERE r.usuario.email = :email AND r.estado IN ('PENDIENTE', 'EN_CURSO')")
    boolean existeReservaActiva(@Param("email") String email);

    List<Reserva> findByEspacioId(Long espacioId);
    @Query("SELECT CASE WHEN COUNT(r) > 0 THEN true ELSE false END " +
            "FROM Reserva r " +
            "WHERE r.espacio.id = :espacioId " +
            "AND r.estado <> 'CANCELADA' " +
            "AND r.fechaInicio < :fechaFin " +
            "AND r.fechaFin > :fechaInicio")
    boolean existeConflictoDeHorario(@Param("espacioId") Long espacioId,
                                     @Param("fechaInicio") LocalDateTime fechaInicio,
                                     @Param("fechaFin") LocalDateTime fechaFin);
}