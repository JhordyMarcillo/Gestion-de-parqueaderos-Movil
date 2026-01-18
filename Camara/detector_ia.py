import cv2
import pickle
import numpy as np
import requests
import time

FUENTE_VIDEO = 'parking1.mp4' 
API_URL = "http://localhost:8080/api"
EMAIL = "camara@gmail.com"
PASSWORD = "123" 
ANCHO_ESPACIO, ALTO_ESPACIO = 70, 150 

def obtener_token():
    try:
        resp = requests.post(f"{API_URL}/auth/login", json={"email": EMAIL, "password": PASSWORD})
        if resp.status_code == 200:
            return resp.json()["token"]
    except:
        print("Error conectando al Backend")
    return None

token = obtener_token()
header = {"Authorization": f"Bearer {token}"} if token else {}

# Cargar posiciones
with open('posiciones_espacios.pkl', 'rb') as f:
    lista_espacios = pickle.load(f)

estado_actual_espacios = ["DESCONOCIDO"] * len(lista_espacios) 

def verificar_espacios(img_procesada):
    global estado_actual_espacios
    espacios_libres = 0

    for i, pos in enumerate(lista_espacios):
        x, y = pos
        
        img_recorte = img_procesada[y:y+ALTO_ESPACIO, x:x+ANCHO_ESPACIO]
        
        count = cv2.countNonZero(img_recorte)

        # 3. UMBRAL: Ajusta este número según la iluminación
        # Si hay menos de 900 pixeles "diferentes", está libre (piso gris).
        # Si hay más, es un auto (muchos bordes y colores).
        limite_ocupacion = 900 

        estado_detectado = "LIBRE" if count < limite_ocupacion else "OCUPADO"
        color = (0, 255, 0) if estado_detectado == "LIBRE" else (0, 0, 255)


        if estado_detectado != estado_actual_espacios[i]:
            estado_actual_espacios[i] = estado_detectado

            id_backend = i + 1 
            print(f"Actualizando Espacio {id_backend} a {estado_detectado}...")
            
            try:
                requests.put(
                    f"{API_URL}/parqueaderos/{id_backend}/estado", 
                    params={"estado": estado_detectado},
                    headers=header
                )
            except Exception as e:
                print(f"Error API: {e}")


        cv2.rectangle(img, pos, (pos[0] + ANCHO_ESPACIO, pos[1] + ALTO_ESPACIO), color, 2)
        cv2.putText(img, str(count), (x, y + ALTO_ESPACIO - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255,255,255), 1)

cap = cv2.VideoCapture(FUENTE_VIDEO)

while True:
    # Bucle de video
    if cap.get(cv2.CAP_PROP_POS_FRAMES) == cap.get(cv2.CAP_PROP_FRAME_COUNT):
        cap.set(cv2.CAP_PROP_POS_FRAMES, 0) 
        
    success, img = cap.read()
    if not success: break

    img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY) # Blanco y negro
    img_blur = cv2.GaussianBlur(img_gray, (3, 3), 1) # Desenfocar un poco para quitar ruido
    
    # Convierte la imagen en solo BLANCO y NEGRO puro
    img_threshold = cv2.adaptiveThreshold(img_blur, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
                                          cv2.THRESH_BINARY_INV, 25, 16)
    
    # Quitar puntitos pequeños
    img_median = cv2.medianBlur(img_threshold, 5)
    kernel = np.ones((3, 3), np.uint8)
    img_dilated = cv2.dilate(img_median, kernel, iterations=1)

    # Llamar a la función de detección
    verificar_espacios(img_dilated)

    cv2.imshow("SISTEMA DE VISIÓN - SMART PARKING", img)
    # cv2.imshow("LO QUE VE LA IA", img_dilated) # Descomenta para ver cómo ve la computadora

    if cv2.waitKey(10) & 0xFF == ord('q'):
        break