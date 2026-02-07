# 🚗 Sistema de Gestión de Parqueaderos Inteligente

![Flutter](https://img.shields.io/badge/Flutter-3.0-blue)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-4.0.1-green)
![Python](https://img.shields.io/badge/Python-3.x-yellow)
![License](https://img.shields.io/badge/License-Propietary-red)

## 📋 Descripción del Proyecto

Sistema integral de gestión de parqueaderos con detección automática de espacios mediante visión artificial. El proyecto está dividido en tres componentes principales que trabajan en conjunto para proporcionar una experiencia completa de administración y uso de parqueaderos.

### ✨ Características Principales

- **🅿️ Gestión de Espacios**: Monitoreo en tiempo real del estado de cada espacio de estacionamiento
- **📡 Integración IoT**: cámaras y sensores Sistema de detección mediante
- **📱 Aplicación Móvil**: Interfaz Flutter para usuarios y administradores
- **🔐 Sistema de Autenticación**: Login seguro con tokens JWT
- **📅 Reservas**: Los usuarios pueden reservar espacios con código QR
- **📊 Panel Administrativo**: Dashboard con estadísticas y reportes
- **🔄 Tiempo Real**: Actualizaciones automáticas cada 3-5 segundos

---

## 🏗️ Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────────┐
│                      SISTEMA DE GESTIÓN DE PARQUEADEROS         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐       │
│   │   FRONTEND  │◄───│   BACKEND    │◄───│   CÁMARA    │       │
│   │   (Flutter) │    │(Spring Boot) │    │  (Python)   │       │
│   └─────────────┘    └─────────────┘    └─────────────┘       │
│         │                  │                   │                │
│         │    REST API      │    WebSocket      │   TCP/HTTP    │
│         └──────────────────┴───────────────────┘                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 Estructura del Proyecto

```
Gestion-de-parqueaderos-Movil/
├── backend/                 # API REST Spring Boot
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/espe/
│   │   │   │   ├── config/          # Configuraciones
│   │   │   │   ├── controller/      # Endpoints REST
│   │   │   │   ├── dto/              # Objetos de transferencia
│   │   │   │   ├── entity/           # Entidades JPA
│   │   │   │   ├── repository/       # Repositorios
│   │   │   │   ├── security/         # Seguridad JWT
│   │   │   │   └── service/          # Lógica de negocio
│   │   │   └── resources/
│   │   │       ├── application.yaml
│   │   │       └── static/
│   │   └── test/
│   ├── pom.xml
│   └── README.md
│
├── frontend/               # Aplicación Flutter
│   ├── lib/
│   │   ├── config/         # Constantes API
│   │   ├── models/         # Modelos de datos
│   │   ├── providers/      # Estado (Provider)
│   │   ├── screens/        # Pantallas UI
│   │   ├── services/       # Servicios API
│   │   ├── widgets/        # Componentes reutilizables
│   │   └── main.dart       # Punto de entrada
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── pubspec.yaml
│   └── README.md
│
├── Camara/                 # Sistema de Visión Artificial
│   ├── detector_ia.py      # Detector de espacios
│   ├── selector.py         # Selector de región
│   ├── parking1.mp4        # Video de prueba
│   └── posiciones_espacios.pkl
│
├── README.md               # Este archivo
└── .gitignore
```

---

## 🛠️ Tecnologías Utilizadas

### Frontend (Flutter)
| Tecnología | Propósito |
|------------|-----------|
| Flutter SDK | Framework multiplataforma |
| Provider | Gestión de estado |
| http | Peticiones HTTP |
| shared_preferences | Almacenamiento local |
| Material 3 | Diseño UI |

### Backend (Spring Boot)
| Tecnología | Propósito |
|------------|-----------|
| Java 25 | Lenguaje de programación |
| Spring Boot 4.0.1 | Framework backend |
| Spring Security | Seguridad y autenticación |
| Spring Data JPA | Persistencia de datos |
| PostgreSQL | Base de datos |
| JWT | Tokens de autenticación |
| Swagger/OpenAPI | Documentación API |

### Visión Artificial (Python)
| Tecnología | Propósito |
|------------|-----------|
| Python | Lenguaje de programación |
| OpenCV | Procesamiento de imágenes |
| scikit-learn | Clasificador SVM |
| NumPy | Manipulación de arrays |

---

## 🚀 Inicio Rápido

### Prerrequisitos

- **JDK 25** o superior
- **PostgreSQL** 13+
- **Flutter** 3.0+
- **Python** 3.8+
- **Maven** 3.8+

### Configuración del Backend

1. Navegar a la carpeta backend:
```bash
cd backend
```

2. Configurar la base de datos en `src/main/resources/application.yaml`:
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/parqueadero_db
    username: tu_usuario
    password: tu_password
  jpa:
    hibernate:
      ddl-auto: update
```

3. Ejecutar la aplicación:
```bash
# Linux/Mac
./mvnw spring-boot:run

# Windows
mvnw.cmd spring-boot:run
```

### Configuración del Frontend

1. Navegar a la carpeta frontend:
```bash
cd frontend
```

2. Instalar dependencias:
```bash
flutter pub get
```

3. Configurar la URL del servidor en `lib/config/constants.dart`:
```dart
static const String baseUrl = 'http://TU_IP:8080/';
```

4. Ejecutar la aplicación:
```bash
flutter run
```

### Configuración de la Cámara

1. Navegar a la carpeta Camara:
```bash
cd Camara
```

2. Instalar dependencias:
```bash
pip install opencv-python numpy scikit-learn joblib
```

3. Ejecutar el detector:
```bash
python detector_ia.py
```

---

## 📡 Endpoints de la API

### Autenticación
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/auth/login` | Iniciar sesión |
| POST | `/api/auth/register` | Registrar usuario |

### Espacios
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/espacios/libres/{id}` | Espacios libres |
| GET | `/api/espacios/todos/{id}` | Todos los espacios |
| POST | `/api/espacios/detectar` | Actualizar desde IoT |

### Reservas
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/reservas/crear` | Crear reserva |
| GET | `/api/reservas/mis-reservas` | Mis reservas |
| PUT | `/api/reservas/cancelar/{id}` | Cancelar reserva |

### Administración
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/admin/stats/dashboard` | Estadísticas |
| GET | `/api/reportes/ocupacion` | Reportes |

---

## 📱 Roles de Usuario

### Cliente
- Ver estado de espacios
- Crear reservas
- Ver sus reservas
- Cancelar reservas

### Administrador
- Todas las funciones del cliente
- Ver estadísticas del sistema
- Acceder al dashboard financiero
- Gestionar espacios

---

## 🔧 Variables de Entorno

### Backend (.env o application.yaml)
```yaml
app:
  jwtSecret: 404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970
  jwtExpirationMs: 86400000
```

### Frontend
```dart
// lib/config/constants.dart
static const String baseUrl = 'http://localhost:8080/';
```

---

## 📊 Base de Datos

### Entidades Principales

```
┌─────────────────┐       ┌──────────────────┐
│    usuarios     │       │   parqueaderos   │
├─────────────────┤       ├──────────────────┤
│ id (PK)         │       │ id (PK)          │
│ nombre          │       │ nombre           │
│ email (UNIQUE)  │       │ direccion        │
│ password        │       │ tarifa_hora      │
│ rol             │       │ latitud          │
└─────────────────┘       │ longitud         │
        │                └──────────────────┘
        │ 1                    │ 1
        ▼                      ▼
┌─────────────────┐       ┌──────────────────┐
│    reservas      │       │    espacios      │
├─────────────────┤       ├──────────────────┤
│ id (PK)         │       │ id (PK)          │
│ usuario_id      │       │ parqueadero_id   │
│ espacio_id      │       │ identificador    │
│ fecha_reserva   │       │ estado           │
│ estado          │       │ es_preferencial  │
│ monto_total     │       └──────────────────┘
│ codigo_qr       │
└─────────────────┘
```

---

## 🧪 Pruebas

### Backend
```bash
cd backend
./mvnw test
```

### Frontend
```bash
cd frontend
flutter test
```

---

## 📦 Deployment

### Backend (JAR)
```bash
cd backend
./mvnw clean package
java -jar target/parqueadero-0.0.1-SNAPSHOT.jar
```

### Frontend
```bash
cd frontend
# Producción
flutter build apk --release
flutter build ipa --release
flutter build web
```

---

## 🤝 Contribución

Este es un proyecto académico de la Universidad de las Fuerzas Armadas ESPE. Para contribuciones, contacta al equipo de desarrollo.

---

## 📝 Licencia

Este proyecto está protegido bajo una licencia propietaria. Consulta los archivos LICENSE.txt en cada módulo para más detalles.

---

## 👥 Equipo de Desarrollo

- **Universidad**: Universidad de las Fuerzas Armadas ESPE
- **Carrera**: Ingeniería en Software
- **Materia**: Desarrollo de Aplicaciones Móviles

---

## 📞 Contacto

Para soporte o consultas:
- **Email**: parking@espe.edu.ec
- **Campus**: Valle de los Ríos

---

## 🔜 Próximas Mejoras

- [ ] Notificaciones push
- [ ] Integración con Google Maps
- [ ] Sistema de pagos en línea
- [ ] App Apple Watch
- [ ] Modo offline

