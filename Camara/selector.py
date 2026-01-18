import cv2
import pickle


# IP  o video ('http://192.x.x.x:8080/video')
FUENTE_VIDEO = 'parking1.mp4' 

try:
    with open('posiciones_espacios.pkl', 'rb') as f:
        lista_espacios = pickle.load(f)
except:
    lista_espacios = []

def mouse_click(events, x, y, flags, params):
    # Ancho y Alto
    width, height = 70, 150 

    if events == cv2.EVENT_LBUTTONDOWN:
        # Clic izquierdo: Agregar espacio
        lista_espacios.append((x, y))
    
    if events == cv2.EVENT_RBUTTONDOWN:
        # Clic derecho: Eliminar espacio cercano
        for i, pos in enumerate(lista_espacios):
            x1, y1 = pos
            if x1 < x < x1 + width and y1 < y < y1 + height:
                lista_espacios.pop(i)

while True:
    cap = cv2.VideoCapture(FUENTE_VIDEO)
    success, img = cap.read()
    
    if not success: 
        break 

    for pos in lista_espacios:
        cv2.rectangle(img, pos, (pos[0] + 70, pos[1] + 150), (255, 0, 255), 2)

    cv2.imshow("(Click Izq: Agregar, Der: Borrar, Q: Guardar)", img)
    cv2.setMouseCallback("(Click Izq: Agregar, Der: Borrar, Q: Guardar)", mouse_click)
    
    if cv2.waitKey(1) & 0xFF == ord('q'):
        # Guardar coordenadas en un archivo
        with open('posiciones_espacios.pkl', 'wb') as f:
            pickle.dump(lista_espacios, f)
        break

cap.release()
cv2.destroyAllWindows()