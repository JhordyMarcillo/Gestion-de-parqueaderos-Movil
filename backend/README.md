# 🚗 Gestión de Parqueaderos - Backend API

## 📋 Descripción del Proyecto

Sistema de gestión de parqueaderos con soporte para reservas, integración con sensores IoT y panel administrativo. Este es el backend desarrollado en **Spring Boot 4.0.1** que proporciona una API REST segura con autenticación JWT.

### ✨ Características Principales

- 🔐 **Autenticación y Autorización**: Registro/Login con tokens JWT
- 🅿️ **Gestión de Espacios**: Consulta de espacios libres y ocupados
- 📅 **Sistema de Reservas**: Creación y gestión de reservas de parqueadero
- 📡 **Integración IoT**: Endpoints para sensores/cámaras de detección
- 📊 **Reportes**: Panel administrativo con historial de ocupación
- 🔄 **Tiempo Real**: Soporte WebSocket para actualizaciones en vivo
- 📖 **Documentación API**: Swagger/OpenAPI 3.0 integrado

---

## 🏗️ Arquitectura del Proyecto

```
parqueadero/
├── config/
│   ├── OpenApiConfig.java      # Configuración de Swagger
│   ├── SecurityConfig.java     # Configuración de seguridad JWT
│   └── WebSocketConfig.java    # Configuración WebSocket
├── controller/
│   ├── AuthController.java     # Endpoints de autenticación
│   ├── EspacioController.java  # Gestión de espacios/IoT
│   ├── ReservaController.java  # Gestión de reservas
│   └── ReporteController.java  # Reportes administrativos
├── dto/
│   ├── request/                # DTOs de entrada
│   └── response/               # DTOs de salida
├── entity/
│   ├── Usuario.java            # Entidad Usuario
│   ├── Parqueadero.java        # Entidad Parqueadero
│   ├── Espacio.java            # Entidad Espacio
│   ├── Reserva.java            # Entidad Reserva
│   └── HistorialOcupacion.java # Entidad Historial
├── repository/
│   └── *Repository.java        # Repositorios JPA
├── security/
│   ├── UserDetailsImpl.java    # Implementación UserDetails
│   └── jwt/
│       ├── JwtAuthFilter.java  # Filtro JWT
│       └── JwtUtils.java       # Utilidades JWT
├── service/impl/
│   ├── AuthService.java
│   ├── EspacioService.java
│   └── ReservaService.java
└── ParqueaderoApplication.java
```

---

## 🛠️ Tecnologías Utilizadas

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| **Java** | 25 | Lenguaje de programación |
| **Spring Boot** | 4.0.1 | Framework principal |
| **Spring Security** | 4.0.1 | Seguridad y autenticación |
| **Spring Data JPA** | 4.0.1 | Persistencia de datos |
| **PostgreSQL** | - | Base de datos relacional |
| **JWT (jjwt)** | 0.11.5 | Tokens de autenticación |
| **SpringDoc OpenAPI** | 2.3.0 | Documentación API |
| **Lombok** | - | Reducción de código boilerplate |
| **Maven** | - | Gestión de dependencias |

---

## 📦 Dependencias Principales

```xml
<!-- Spring Boot Starters -->
spring-boot-starter-data-jpa      # Persistencia JPA
spring-boot-starter-security      # Seguridad
spring-boot-starter-webmvc        # API REST
spring-boot-starter-websocket     # WebSocket en tiempo real

<!-- Base de Datos -->
postgresql                        # Driver PostgreSQL

<!-- Seguridad -->
jjwt-api, jjwt-impl, jjwt-jackson # JWT

<!-- Documentación -->
springdoc-openapi-starter-webmvc-ui

<!-- Utilidades -->
lombok                            # Anotaciones
```

---

## 🚀 Configuración y Ejecución

### Prerrequisitos

- ☕ **Java JDK 25** o superior
- 🐘 **PostgreSQL** instalado y ejecutándose
- 📦 **Maven** (o usar el wrapper incluido)

### Configuración de Base de Datos

Edita el archivo `src/main/resources/application.yaml`:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:{port}/{db_name}
    username: {username}
    password: {password}
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true

server:
  port: 8080
```

### Variables de Entorno (Opcional)

```yaml
app:
  jwtSecret: 404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970
  jwtExpirationMs: 86400000
```

### Ejecutar la Aplicación

#### Usando Maven Wrapper (Linux/Mac):
```bash
./mvnw spring-boot:run
```

#### Usando Maven (Windows):
```bash
mvnw.cmd spring-boot:run
```

#### Compilar JAR:
```bash
./mvnw clean package
java -jar target/parqueadero-0.0.1-SNAPSHOT.jar
```

---

## 📡 API Endpoints

### 🔓 Autenticación

| Método | Endpoint | Descripción | Acceso |
|--------|----------|-------------|--------|
| POST | `/api/auth/login` | Iniciar sesión | Público |
| POST | `/api/auth/register` | Registrar nuevo usuario | Público |

### 🅿️ Espacios (App Móvil)

| Método | Endpoint | Descripción | Acceso |
|--------|----------|-------------|--------|
| GET | `/api/espacios/libres/{parqueaderoId}` | Listar espacios libres | Autenticado |
| GET | `/api/espacios/todos/{parqueaderoId}` | Ver todos los espacios | Autenticado |

### 🅿️ Espacios (IoT/Sensores)

| Método | Endpoint | Descripción | Acceso |
|--------|----------|-------------|--------|
| POST | `/api/espacios/detectar` | Actualizar estado desde cámara | Público |

### 📅 Reservas

| Método | Endpoint | Descripción | Acceso |
|--------|----------|-------------|--------|
| POST | `/api/reservas` | Crear nueva reserva | Autenticado |
| GET | `/api/reservas/mis-reservas` | Ver mis reservas | Autenticado |

### 📊 Reportes (Admin)

| Método | Endpoint | Descripción | Acceso |
|--------|----------|-------------|--------|
| GET | `/api/reportes/ocupacion` | Historial de sensores | Admin only |

---

## 🔐 Modelos de Datos

### Usuario
```java
- id: Long
- nombreCompleto: String
- email: String (único)
- password: String (encriptada)
- rol: String (CLIENTE/ADMIN)
- fechaRegistro: LocalDate
```

### Parqueadero
```java
- id: Long
- nombre: String
- direccion: String
- latitud: Double
- longitud: Double
- tarifaHora: BigDecimal
- activo: Boolean
```

### Espacio
```java
- id: Long
- parqueadero: Parqueadero
- identificador: String (ej: "A1")
- estado: String (OCUPADO/LIBRE)
- esPreferencial: Boolean
```

### Reserva
```java
- id: Long
- usuario: Usuario
- espacio: Espacio
- fechaReserva: LocalDateTime
- fechaInicio: LocalDateTime
- fechaFin: LocalDateTime
- estado: String (PENDIENTE/PAGADA/FINALIZADA)
- montoTotal: BigDecimal
- codigoQr: String
```

---

## 🔒 Seguridad JWT

### Flujo de Autenticación

1. **Registro/Login**: El usuario envía credenciales al endpoint `/api/auth/login`
2. **Generación de Token**: Si las credenciales son válidas, se genera un JWT
3. **Envío de Token**: El token se devuelve en la respuesta
4. **Uso del Token**: El cliente incluye el token en el header `Authorization: Bearer <token>`
5. **Validación**: El `JwtAuthFilter` valida el token en cada request protegido

### Roles y Permisos

| Rol | Permisos |
|-----|----------|
| **CLIENTE** | Crear reservas, ver sus reservas, consultar espacios |
| **ADMIN** | Todos los anteriores + ver reportes, acceder a historial |

---

## 📖 Documentación API (Swagger)

Una vez ejecutando la aplicación, accede a:

```
http://localhost:8080/swagger-ui/index.html
```

Endpoints disponibles con:
- Descripción detallada
- Parámetros requeridos
- Ejemplos de request/response
- Posibilidad de probar directamente desde la UI

---

## 🗄️ Esquema de Base de Datos

```
┌─────────────────┐       ┌──────────────────┐
│    usuarios     │       │   parqueaderos   │
├─────────────────┤       ├──────────────────┤
│ id (PK)         │       │ id (PK)          │
│ nombre_completo │       │ nombre           │
│ email (UNIQUE)  │       │ direccion        │
│ password        │       │ latitud          │
│ rol             │       │ longitud         │
│ fecha_registro  │       │ tarifa_hora      │
└─────────────────┘       │ activo           │
        │                 └──────────────────┘
        │                        │
        │ 1                      │ 1
        ▼                        ▼
┌─────────────────┐       ┌──────────────────┐
│    reservas     │       │    espacios      │
├─────────────────┤       ├──────────────────┤
│ id (PK)         │       │ id (PK)          │
│ usuario_id (FK) │       │ parqueadero_id   │
│ espacio_id (FK) │       │ identificador    │
│ fecha_reserva   │       │ estado           │
│ fecha_inicio    │       │ es_preferencial  │
│ fecha_fin       │       └──────────────────┘
│ estado          │              │
│ monto_total     │              │ 1
│ codigo_qr       │              ▼
└─────────────────┘       ┌──────────────────┐
                          │ historial_ocup   │
                          ├──────────────────┤
                          │ id (PK)          │
                          │ espacio_id       │
                          │ evento           │
                          │ fecha_evento     │
                          │ confianza        │
                          └──────────────────┘
```

---


## 📁 Estructura de Archivos

```
backend/
├── .gitattributes
├── .gitignore
├── pom.xml                          # Configuración Maven
├── README.md                        # Este archivo
├── mvnw / mvnw.cmd                  # Maven Wrapper
└── src/
    ├── main/
    │   ├── java/com/espe/parqueaderos/parqueadero/
    │   │   ├── ParqueaderoApplication.java
    │   │   ├── config/
    │   │   ├── controller/
    │   │   ├── dto/
    │   │   ├── entity/
    │   │   ├── repository/
    │   │   ├── security/
    │   │   └── service/
    │   └── resources/
    │       ├── application.yaml     # Configuración
    │       ├── static/
    │       └── templates/
    └── test/
        └── java/com/espe/parqueaderos/parqueadero/
            └── ParqueaderoApplicationTests.java
```

---

## 📝 Licencia

Este proyecto está protegido bajo una licencia propietaria.
No se permite el uso, modificación ni redistribución del código sin consentimiento del autor.

Consulta el archivo LICENSE.txt para más detalles.
---