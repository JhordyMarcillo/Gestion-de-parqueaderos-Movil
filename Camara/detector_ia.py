import cv2
import pickle
import numpy as np
import requests
import time

# --- CONFIGURACIÓN ---
FUENTE_VIDEO = 'parking1.mp4' 
API_URL = "http://localhost:8080/api"
EMAIL = "camara@gmail.com" # Tu usuario cámara
PASSWORD = "123" 

# --- AUTENTICACIÓN ---
def obtener_token():
    try:
        resp = requests.post(f"{API_URL}/auth/login", json={"email": EMAIL, "password": PASSWORD})
        if resp.status_code == 200:
            return resp.json()["token"]
    except:
        print("❌ Error conectando al Backend")
    return None

token = obtener_token()
header = {"Authorization": f"Bearer {token}"} if token else {}

# Cargar posiciones (Ahora incluyen ancho y alto)
try:
    with open('posiciones_espacios.pkl', 'rb') as f:
        lista_espacios = pickle.load(f)
except:
    print("❌ No encontré el archivo de posiciones. Ejecuta selector.py primero.")
    lista_espacios = []

estado_actual_espacios = ["DESCONOCIDO"] * len(lista_espacios) 

def verificar_espacios(img_procesada, img_original):
    global estado_actual_espacios

    for i, pos in enumerate(lista_espacios):
        # Ahora desempaquetamos 4 valores
        x, y, w, h = pos
        
        # Recortar usando las dimensiones específicas de este cuadro
        img_recorte = img_procesada[y:y+h, x:x+w]
        
        # Contar pixeles
        count = cv2.countNonZero(img_recorte)

        # UMBRAL: Como ahora los tamaños varían (horizontales vs verticales),
        # el umbral debería ser proporcional al área, pero para simplificar
        # usaremos un valor fijo o ajustado.
        # Si tienes problemas, sube o baja este 900.
        limite_ocupacion = 850 

        estado_detectado = "LIBRE" if count < limite_ocupacion else "OCUPADO"
        
        # Colores: Verde (Libre), Rojo (Ocupado)
        color = (0, 255, 0) if estado_detectado == "LIBRE" else (0, 0, 255)

        # --- LÓGICA DE ENVÍO AL BACKEND ---
        if estado_detectado != estado_actual_espacios[i]:
            estado_actual_espacios[i] = estado_detectado
            
            # EL ID DE LA BASE DE DATOS ES EL ORDEN DE DIBUJO + 1
            id_backend = i + 1 
            print(f"📡 Espacio ID {id_backend} -> {estado_detectado} (Pixeles: {count})")
            
            if token:
                try:
                    requests.put(
                        f"{API_URL}/parqueaderos/{id_backend}/estado", 
                        params={"estado": estado_detectado},
                        headers=header
                    )
                except Exception as e:
                    print(f"Error API: {e}")

        # Dibujar en pantalla
        cv2.rectangle(img_original, (x, y), (x + w, y + h), color, 2)
        # Mostrar el ID y la cuenta de pixeles
        cv2.putText(img_original, f"ID:{i+1}", (x, y - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)

cap = cv2.VideoCapture(FUENTE_VIDEO)

while True:
    if cap.get(cv2.CAP_PROP_POS_FRAMES) == cap.get(cv2.CAP_PROP_FRAME_COUNT):
        cap.set(cv2.CAP_PROP_POS_FRAMES, 0)
        
    success, img = cap.read()
    if not success: break

    # Procesamiento de imagen
    img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    img_blur = cv2.GaussianBlur(img_gray, (3, 3), 1)
    img_threshold = cv2.adaptiveThreshold(img_blur, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
                                          cv2.THRESH_BINARY_INV, 25, 16)
    img_median = cv2.medianBlur(img_threshold, 5)
    kernel = np.ones((3, 3), np.uint8)
    img_dilated = cv2.dilate(img_median, kernel, iterations=1)

    verificar_espacios(img_dilated, img)

    cv2.imshow("IA DETECTOR - SOPORTE ROTACION", img)
    
    if cv2.waitKey(10) & 0xFF == ord('q'):
        break