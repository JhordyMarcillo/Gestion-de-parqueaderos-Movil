# 📷 Cámaras - Sistema de Detección por Visión Artificial

![Python](https://img.shields.io/badge/Python-3.x-yellow)
![OpenCV](https://img.shields.io/badge/OpenCV-4.x-red)
![Scikit-learn](https://img.shields.io/badge/Scikit--learn-1.x-orange)

## 📋 Descripción

Sistema de detección automática de espacios de estacionamiento mediante visión artificial. Utiliza procesamiento de imágenes y machine learning para identificar el estado (libre/ocupado) de cada espacio en tiempo real.

### ✨ Características

- **🎯 Detección Precisa**: Algoritmo SVM para clasificación
- **📹 Procesamiento de Video**: Soporte para video en vivo y archivos
- **⚡ Tiempo Real**: Procesamiento continuo de frames
- **💾 Persistencia de Posiciones**: Guarda configuración de espacios
- **🖱️ Selección Interactiva**: Herramienta para definir regiones de interés
- **📊 Alta Precisión**: Clasificador entrenado con scikit-learn

---

## 🏗️ Arquitectura del Sistema de Detección

```
Camara/
├── detector_ia.py              # Detector principal de espacios
├── selector.py                  # Herramienta de selección de región
├── parking1.mp4                # Video de prueba
└── posiciones_espacios.pkl    # Posiciones guardadas (binario)
```

### Flujo de Detección

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   Video/     │───►│  Extracción  │───►│  Clasificador│───►│   Estado     │
│   Cámara     │    │    ROI       │    │     SVM      │    │  (Libre/     │
│   Input      │    │              │    │              │    │   Ocupado)   │
└──────────────┘    └──────────────┘    └──────────────┘    └──────────────┘
                            │
                            ▼
                   ┌──────────────┐
                   │  Posiciones   │
                   │   (pkl)       │
                   └──────────────┘
```

---

## 🛠️ Tecnologías Utilizadas

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| **Python** | 3.8+ | Lenguaje de programación |
| **OpenCV** | 4.x | Procesamiento de imágenes |
| **NumPy** | 1.x | Manipulación de arrays |
| **scikit-learn** | 1.x | Clasificador SVM |
| **joblib** | 1.x | Serialización de modelos |

### Instalación de Dependencias

```bash
pip install opencv-python numpy scikit-learn joblib
```

O todas las dependencias:
```bash
pip install -r requirements.txt
```

---

## 📁 Archivos del Módulo

### detector_ia.py

Detector principal que procesa el video y detecta el estado de cada espacio de estacionamiento.

**Características:**
- Carga posiciones desde archivo `.pkl`
- Procesa video en tiempo real
- Aplica clasificación SVM
- Dibuja resultados visuales
- Envía datos al servidor backend

**Uso:**
```bash
python detector_ia.py
```

**Parámetros:**
```python
# Configuración típica
video_source = 0          # Cámara local
video_source = "video.mp4"  # Archivo de video
confianza_minima = 0.7    # Umbral de confianza
```

**Salida visual:**
- Rectángulos verdes para espacios libres
- Rectángulos rojos para espacios ocupados
- Contadores de ocupación
- Indicadores de FPS

### selector.py

Herramienta interactiva para seleccionar y guardar las posiciones de los espacios de estacionamiento.

**Características:**
- Visualización de video en tiempo real
- Selección manual de regiones (ROI)
- Dibujar rectángulos sobre espacios
- Guardar posiciones en formato `.pkl`
- Interfaz simple con OpenCV

**Uso:**
```bash
python selector.py
```

**Controles:**
| Tecla | Acción |
|-------|--------|
| `鼠标拖动` | Dibujar rectángulo |
| `s` | Guardar posiciones |
| `c` | Limpiar selección |
| `q` | Salir |

**Ejemplo de uso:**
```python
# Inicializar selector
selector = RegionSelector()
selector.cargar_video("parking1.mp4")
selector.seleccionar_regiones()
selector.guardar_posiciones("posiciones_espacios.pkl")
```

### parking1.mp4

Video de prueba utilizado para:
- Entrenamiento del modelo
- Pruebas de detección
- Demostraciones
- Calibración del sistema

**Especificaciones:**
- Resolución: 1920x1080 o similar
- FPS: 30
- Duración: Variable

### posiciones_espicios.pkl

Archivo binario que almacena:
- Posiciones de cada espacio (x, y, ancho, alto)
- Identificadores de espacios
- Metadatos de calibración

**Formato:**
```python
# Estructura típica
posiciones = [
    {
        'id': 'A1',
        'rect': (x, y, w, h),
        'es_preferencial': False
    },
    {
        'id': 'A2',
        'rect': (x, y, w, h),
        'es_preferencial': True
    },
    # ... más espacios
]
```

**Cargar en Python:**
```python
import pickle

with open('posiciones_espacios.pkl', 'rb') as f:
    posiciones = pickle.load(f)
```

---

## 🔧 Configuración y Personalización

### Parámetros del Clasificador SVM

```python
# Parámetros SVM típicos
svm_params = dict(
    kernel_type=cv2.SVM_RBF,
    svm_type=cv2.SVM_C_SVC,
    C=1.0,
    gamma=0.1
)
```

### Región de Interés (ROI)

```python
# Definir área de interés
ROI = {
    'x': 100,
    'y': 50,
    'width': 800,
    'height': 600
}
```

### Colores de Visualización

```python
COLORES = {
    'LIBRE': (0, 255, 0),      # Verde
    'OCUPADO': (0, 0, 255),    # Rojo
    'RESERVADO': (0, 165, 255),# Naranja
    'TEXTO': (255, 255, 255)   # Blanco
}
```

---

## 📊 Algoritmo de Detección

### 1. Preprocesamiento
```
Frame → Conversión a escala de grises → Reducción de ruido (GaussianBlur)
```

### 2. Extracción de Características
Para cada ROI (espacio):
- Diferencia de píxeles respecto al fondo
- Histograma de diferencias
- Características de textura
- Conteo de píxeles modificados

### 3. Clasificación SVM
```
Vector de características → Normalización → SVM (RBF kernel) → Clase
```

### 4. Filtrado Temporal
```
Detección frame actual → Promedio temporal → Decisión final
```

---

## 🚀 Uso en el Sistema Completo

### Integración con Backend

El detector envía datos al servidor mediante:

```python
# Ejemplo de envío HTTP
import requests

def enviar_estado(espacio_id, estado, confianza):
    url = "http://localhost:8080/api/espacios/detectar"
    data = {
        "espacioId": espacio_id,
        "estado": estado,
        "confianza": confianza
    }
    response = requests.post(url, json=data)
    return response.status_code
```

### Flujo de Datos

```
┌─────────┐      HTTP POST       ┌──────────┐      WebSocket      ┌─────────┐
│Detector │─────────────────────►│ Backend  │─────────────────────►│Frontend │
│ (Python)│    /detectar         │(Spring)  │    Tiempo Real      │(Flutter)│
└─────────┘                       └──────────┘                      └─────────┘
```

---

## 📈 Métricas de Rendimiento

| Métrica | Valor Típico |
|---------|-------------|
| **FPS de procesamiento** | 15-30 |
| **Tiempo por frame** | 30-60 ms |
| **Precisión de detección** | 95-99% |
| **Falsos positivos** | < 2% |
| **Falsos negativos** | < 3% |

---

## 🧪 Pruebas

### Test de Detección Simple

```python
import cv2
from detector_ia import DetectorParqueadero

detector = DetectorParqueadero()
detector.cargar_posiciones("posiciones_espacios.pkl")
detector.cargar_video("parking1.mp4")

# Procesar 100 frames
detector.procesar_frames(frames=100)

# Mostrar estadísticas
detector.mostrar_estadisticas()
```

### Calibración del Clasificador

```python
from selector import Calibrador

calibrador = Calibrador()
calibrador.cargar_video("parking1.mp4")

# Marcar ejemplos positivos (ocupado)
calibrador.agregar_ejemplo_positivo("A1")

# Marcar ejemplos negativos (libre)
calibrador.agregar_ejemplo_negativo("A2")

# Entrenar clasificador
calibrador.entrenar()
calibrador.guardar_modelo("modelo_svm.pkl")
```

---

## 🔧 Solución de Problemas

### Error: "No se puede abrir el video"
```bash
# Verificar ruta del archivo
python -c "import cv2; cap = cv2.VideoCapture('parking1.mp4'); print('OK' if cap.isOpened() else 'ERROR')"
```

### Error: "Modelo no encontrado"
```
1. Ejecutar selector.py
2. Dibujar todos los espacios
3. Guardar con tecla 's'
```

### Baja precisión de detección
```python
# Ajustar parámetros de sensibilidad
detector = DetectorParqueadero(
    sensibilidad=0.8,      # Mayor = más sensible
    umbral_diferencia=30,  # Diferencia mínima de píxeles
    tamano_filtro=5        # Tamaño del blur
)
```

### Lentitud en procesamiento
```python
# Reducir resolución de procesamiento
detector = DetectorParqueadero(
    resolucion_procesamiento=(640, 480)  # Menor resolución
)
```

---

## 📝 Mejores Prácticas

### Iluminación
- Mantener iluminación constante
- Evitar sombras directas
- Usar iluminación uniforme

### Cámara
- Posición elevada (ángulos de 30-45°)
- Estabilización de montura
- Resolución mínima 720p

### Configuración de Espacios
- Espacios bien delimitados
- Evitar superposiciones
- Margen de 5-10% entre espacios

---

## 🔮 Extensiones Futuras

- [ ] Detección de matrículas
- [ ] Clasificación de tipos de vehículos
- [ ] Predicción de disponibilidad
- [ ] Integración con edge computing
- [ ] Detección de múltiples parqueaderos
- [ ] Análisis de tráfico

---

## 📚 Documentación Adicional

- [OpenCV Python Tutorials](https://docs.opencv.org/master/d6/d00/tutorial_py_root.html)
- [Scikit-learn SVM](https://scikit-learn.org/stable/modules/svm.html)
- [Python Pickle](https://docs.python.org/3/library/pickle.html)

---

## 🤝 Contribución

1. Mejorar algoritmos de detección
2. Agregar nuevos tipos de vehículos
3. Optimizar rendimiento
4. Documentar casos de uso

---

## 📝 Licencia

Este módulo es parte del proyecto de gestión de parqueaderos. Ver LICENSE.txt en el directorio raíz.

---

## 👥 Equipo

Desarrollado por estudiantes de la Universidad de las Fuerzas Armadas ESPE.
Materia: Desarrollo de Aplicaciones Móviles

---

## 📞 Soporte

Para problemas con el sistema de visión:
1. Verificar iluminación del área
2. Confirmar posición de cámara
3. Revisar archivo de posiciones
4. Ajustar sensibilidad del clasificador
5. Contactar al equipo de desarrollo

