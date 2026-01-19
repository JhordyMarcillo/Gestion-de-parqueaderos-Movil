import cv2
import pickle

ANCHO_VERTICAL, ALTO_VERTICAL = 60, 140 #cuadro dibujado
FUENTE_VIDEO = 'parking1.mp4' # O tu IP

es_horizontal = False 

try:
    with open('posiciones_espacios.pkl', 'rb') as f:
        lista_espacios = pickle.load(f)
except:
    lista_espacios = []

def mouse_click(events, x, y, flags, params):
    global es_horizontal

    w = ALTO_VERTICAL if es_horizontal else ANCHO_VERTICAL
    h = ANCHO_VERTICAL if es_horizontal else ALTO_VERTICAL

    if events == cv2.EVENT_LBUTTONDOWN:
        # Orden
        lista_espacios.append((x, y, w, h))
    
    if events == cv2.EVENT_RBUTTONDOWN:
        for i, pos in enumerate(lista_espacios):
            x1, y1, w1, h1 = pos
            if x1 < x < x1 + w1 and y1 < y < y1 + h1:
                lista_espacios.pop(i)

while True:
    cap = cv2.VideoCapture(FUENTE_VIDEO)
    success, img = cap.read()
    
    if not success: 
        break 

    for i, pos in enumerate(lista_espacios):
        x, y, w, h = pos
        cv2.rectangle(img, (x, y), (x + w, y + h), (255, 0, 255), 2)
        # Dibujamos el ID para que sepas cuál es cual en la Base de Datos
        cv2.putText(img, f"ID:{i+1}", (x + 5, y + 20), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255,255,255), 2)


    cursor_w = ALTO_VERTICAL if es_horizontal else ANCHO_VERTICAL
    cursor_h = ANCHO_VERTICAL if es_horizontal else ALTO_VERTICAL
    
    # Mostrar instrucciones en pantalla
    modo = "HORIZONTAL" if es_horizontal else "VERTICAL"
    cv2.putText(img, f"MODO: {modo} (Presiona 'R' para rotar)", (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 255), 2)
    cv2.putText(img, f"Proximo ID a crear: {len(lista_espacios) + 1}", (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)

    cv2.imshow("MAESTRO DE ESPACIOS", img)
    cv2.setMouseCallback("MAESTRO DE ESPACIOS", mouse_click)
    
    key = cv2.waitKey(1) & 0xFF
    if key == ord('q'):
        with open('posiciones_espacios.pkl', 'wb') as f:
            pickle.dump(lista_espacios, f)
        break
    elif key == ord('r'): # Tecla R para Rotar
        es_horizontal = not es_horizontal

cap.release()
cv2.destroyAllWindows()