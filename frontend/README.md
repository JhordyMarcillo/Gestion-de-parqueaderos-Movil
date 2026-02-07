# 🚗 Frontend - Aplicación Móvil Flutter

![Flutter](https://img.shields.io/badge/Flutter-3.0-blue)
![Dart](https://img.shields.io/badge/Dart-3.0-blue)
![Platform](https://img.shields.io/badge/Platform-Android%20%26%20iOS-green)

## 📋 Descripción

Aplicación móvil desarrollada en Flutter para el sistema de gestión de parqueaderos. Permite a usuarios y administradores visualizar el estado de espacios, realizar reservas y gestionar el parqueadero de forma remota.

### ✨ Características

- **🔐 Autenticación Segura**: Login con tokens JWT
- **📊 Dashboard en Tiempo Real**: Visualización del estado del parqueadero
- **🅿️ Mapa de Zonas**: Interfaz visual por zonas (A, B, C, D)
- **📅 Sistema de Reservas**: Reserva de espacios con código QR
- **👤 Roles de Usuario**: Diferentes vistas para Cliente y Admin
- **🔄 Sincronización Automática**: Actualización cada 3-5 segundos
- **📱 Diseño Material 3**: Interfaz moderna y intuitiva

---

## 🏗️ Arquitectura

```
frontend/
├── android/              # Configuración Android
├── ios/                 # Configuración iOS
├── lib/
│   ├── main.dart        # Punto de entrada
│   ├── config/
│   │   └── constants.dart     # URLs y constantes API
│   ├── models/
│   │   ├── auth_response.dart  # Modelo de autenticación
│   │   └── parking_model.dart  # Modelo de espacios
│   ├── providers/
│   │   ├── auth_provider.dart  # Estado autenticación
│   │   └── parking_provider.dart # Estado parqueadero
│   ├── screens/
│   │   ├── login_screen.dart   # Pantalla login
│   │   ├── home_screen.dart    # Pantalla principal usuario
│   │   ├── admin_screen.dart   # Pantalla administrador
│   │   ├── reservations_screen.dart # Mis reservas
│   │   ├── SectionDetailScreen.dart # Detalle zona
│   │   ├── AdminSectionDetailScreen.dart # Detalle zona (Admin)
│   │   └── AdminDashboardScreen.dart # Dashboard financiero
│   ├── services/
│   │   └── auth_service.dart   # Servicio autenticación
│   └── widgets/
│       └── MapaNavegacion.dart  # Componente navegación
├── pubspec.yaml
└── README.md
```

---

## 🛠️ Tecnologías

| Paquete | Versión | Propósito |
|---------|---------|-----------|
| flutter | 3.x | Framework principal |
| provider | ^6.0.5 | Gestión de estado |
| http | ^1.1.0 | Peticiones HTTP |
| shared_preferences | ^2.2.2 | Almacenamiento local |
| intl | ^0.18.1 | Formateo de fechas |
| google_fonts | ^5.1.0 | Tipografías |

---

## 📱 Pantallas

### 🔓 LoginScreen
Pantalla de autenticación con:
- Campo de email con validación
- Campo de contraseña (ocultable)
- Indicador de carga
- Navegación según rol (Admin/User)
- Diseño moderno con tarjeta

### 🏠 HomeScreen (Usuario)
Pantalla principal con:
- Header con estado del parqueadero
- Leyenda de colores (Libre/Ocupado/Reservado)
- Mapa visual de zonas (A, B, C, D)
- Contadores por estado
- Acceso a reservas
- Menú de usuario

### 👨‍💼 AdminScreen
Panel de administración con:
- KPI de ocupación
- Mapa de zonas interactivo
- Indicador "En línea"
- Acceso a dashboard financiero
- Cierre de sesión

### 📅 MyReservationsScreen
Gestión de reservas del usuario:
- Lista de reservas activas
- Información de cada reserva
- Opción de cancelación
- Códigos QR

### 📍 SectionDetailScreen
Detalle de zona específica:
- Lista de espacios
- Estados visuales
- Acción de reservar
- Contadores por estado

### 📊 AdminDashboardScreen
Dashboard financiero:
- Estadísticas de ocupación
- Ingresos
- Gráficos
- Reportes

---

## 🗂️ Modelos de Datos

### Espacio
```dart
class Espacio {
  int id;
  String identificador;    // ej: "A1", "B3"
  String estado;           // LIBRE, OCUPADO, RESERVADO, MANTENIMIENTO
  bool esPreferencial;
}
```

### AuthResponse
```dart
class AuthResponse {
  String token;
  String type;
  int id;
  String email;
  String? rol;             // USER o ADMIN
}
```

---

## 🔐 Proveedores de Estado

### AuthProvider
Gestiona el estado de autenticación del usuario.

**Métodos:**
- `login(String email, String password)` → `Future<bool>`
- `logout()` → `void`
- `token` → String?
- `isLoading` → bool

**Características:**
- Persistencia en SharedPreferences
- Timeout de 5 segundos
- Manejo de errores de red

### ParkingProvider
Gestiona el estado del parqueadero y reservas.

**Métodos:**
- `cargarEspacios({bool checkBackground})` → `Future<void>`
- `cambiarEstadoEspacio(int id, String estado)` → `Future<bool>`
- `reservarEspacio(int espacioId, int horas)` → `Future<Map>`
- `cargarMisReservas()` → `Future<void>`
- `cancelarReserva(int id)` → `Future<bool>`
- `cargarEstadisticas()` → `Future<void>`

**Propiedades:**
- `espacios` → List<Espacio>
- `misReservas` → List<dynamic>
- `stats` → Map<String, dynamic>
- `isLoading` → bool

---

## ⚙️ Configuración

### Constantes API

```dart
// lib/config/constants.dart
class ApiConstants {
  static const String baseUrl = 'http://192.xx.xx.xx:8080/';
  static const String loginEndpoint = 'api/auth/login';
  static const String registerEndpoint = 'api/auth/register';
  static const String parkingEndpoint = 'api/espacios';
}
```

> ⚠️ **Importante**: Cambiar `192.xx.xx.xx` por la IP del servidor backend

---

## 🚀 Instalación y Ejecución

### Prerrequisitos
- Flutter SDK 3.0+
- Android Studio / VS Code
- Emulador Android o dispositivo físico

### Pasos

1. **Instalar dependencias**
```bash
flutter pub get
```

2. **Ejecutar en desarrollo**
```bash
flutter run
```

3. **Ejecutar con modo debug**
```bash
flutter run --debug
```

4. **Build para Android**
```bash
flutter build apk --release
```

5. **Build para iOS**
```bash
flutter build ipa --release
```

6. **Build para Web**
```bash
flutter build web
```

---

## 📡 Integración con Backend

### Endpoints Consumidos

| Endpoint | Provider | Descripción |
|----------|----------|-------------|
| `POST /api/auth/login` | AuthProvider | Autenticación |
| `GET /api/espacios/todos/{id}` | ParkingProvider | Lista espacios |
| `PUT /api/parqueaderos/{id}/estado` | ParkingProvider | Cambiar estado |
| `POST /api/reservas/crear` | ParkingProvider | Crear reserva |
| `GET /api/reservas/mis-reservas` | ParkingProvider | Mis reservas |
| `PUT /api/reservas/cancelar/{id}` | ParkingProvider | Cancelar |
| `GET /api/admin/stats/dashboard` | ParkingProvider | Stats |

### Headers de Autorización
```dart
headers: {
  "Content-Type": "application/json",
  "Authorization": "Bearer $token",
}
```

---

## 🎨 Personalización

### Colores por Estado

```dart
const Color LIBRE = Colors.green;
const Color OCUPADO = Colors.red;
const Color RESERVADO = Colors.orange;
const Color MANTENIMIENTO = Colors.grey;
```

### Zonas del Parqueadero

| Zona | Color | Orientación |
|------|-------|-------------|
| A | Verde (#10B981) | Horizontal |
| B | Azul (#0EA5E9) | Vertical |
| C | Púrpura (#8B5CF6) | Horizontal |
| D | Naranja (#F59E0B) | Horizontal |

---

## 📂 Estructura de Archivos Detallada

```
lib/
├── main.dart                           # Entry point
├── config/
│   └── constants.dart                  # API constants
├── models/
│   ├── auth_response.dart              # Auth model
│   └── parking_model.dart              # Parking model
├── providers/
│   ├── auth_provider.dart              # Auth state
│   └── parking_provider.dart           # Parking state
├── services/
│   └── auth_service.dart               # Auth service
├── screens/
│   ├── login_screen.dart               # Login UI
│   ├── home_screen.dart                # User home
│   ├── admin_screen.dart               # Admin home
│   ├── reservations_screen.dart        # User reservations
│   ├── SectionDetailScreen.dart        # Zone detail (User)
│   ├── AdminSectionDetailScreen.dart   # Zone detail (Admin)
│   └── AdminDashboardScreen.dart       # Admin dashboard
└── widgets/
    └── MapaNavegacion.dart             # Navigation widget
```

---

## 🧪 Pruebas

### Ejecutar pruebas unitarias
```bash
flutter test
```

### Verificar dependencias
```bash
flutter pub deps
```

### Analizar código
```bash
flutter analyze
```

---

## 📱 Permisos Requeridos

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### iOS (ios/Runner/Info.plist)
```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Para mostrar la ubicación del parqueadero</string>
```

---

## 🔧 Solución de Problemas

### Error de conexión
```
☠Error de conexión: $e
```
- Verificar que el backend esté ejecutándose
- Comprobar la IP en `constants.dart`
- Revisar firewall

### Token expirado
- El usuario será redirigido al login
- Cerrar sesión y volver a iniciar

### Slow mode en Android
```bash
flutter run --no-sound-null-safety
```

---

## 📈 Métricas de Rendimiento

- **Tiempo de carga inicial**: ~2-3 segundos
- **Actualización de datos**: 3-5 segundos (automático)
- **Tamaño APK release**: ~15-20 MB
- **Compatibilidad**: Android 5.0+ / iOS 11.0+

---

## 🤝 Contribución

1. Fork del proyecto
2. Crear rama feature (`git checkout -b feature/amazing`)
3. Commit cambios (`git commit -m 'Add amazing feature'`)
4. Push a la rama (`git push origin feature/amazing`)
5. Crear Pull Request

---

## 📝 Licencia

Ver LICENSE.txt en el directorio raíz del proyecto.

---

## 👥 Equipo

Desarrollado por estudiantes de la Universidad de las Fuerzas Armadas ESPE.

---

## 📞 Soporte

Para dudas o problemas:
- Crear un issue en GitHub
- Contactar al equipo de desarrollo
- Consultar la documentación del backend

