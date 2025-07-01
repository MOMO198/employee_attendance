from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import face_recognition
import numpy as np
import cv2
from PIL import Image
import io
import base64
import requests
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Configuration CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class FaceVerificationRequest(BaseModel):
    current_image: str
    profile_image_url: str

def load_image_from_base64(base64_string: str) -> np.ndarray:
    try:
        image_data = base64.b64decode(base64_string)
        image = Image.open(io.BytesIO(image_data))
        return np.array(image)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Erreur lors du chargement de l'image: {str(e)}")

def load_image_from_url(url: str) -> np.ndarray:
    try:
        response = requests.get(url)
        image = Image.open(io.BytesIO(response.content))
        return np.array(image)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Erreur lors du chargement de l'image: {str(e)}")

def get_face_encodings(image: np.ndarray) -> np.ndarray:
    # Convertir l'image en RGB si nécessaire
    if len(image.shape) == 2:
        image = cv2.cvtColor(image, cv2.COLOR_GRAY2RGB)
    elif image.shape[2] == 4:
        image = cv2.cvtColor(image, cv2.COLOR_RGBA2RGB)

    # Détecter les visages
    face_locations = face_recognition.face_locations(image)
    if not face_locations:
        return None

    # Obtenir les encodages des visages
    face_encodings = face_recognition.face_encodings(image, face_locations)
    return face_encodings[0] if face_encodings else None

@app.post("/verify-face")
async def verify_face(request: FaceVerificationRequest):
    try:
        # Charger les images
        current_image = load_image_from_base64(request.current_image)
        profile_image = load_image_from_url(request.profile_image_url)

        # Obtenir les encodages des visages
        current_face_encoding = get_face_encodings(current_image)
        profile_face_encoding = get_face_encodings(profile_image)

        if current_face_encoding is None or profile_face_encoding is None:
            return {
                "verified": False,
                "error": "Aucun visage détecté dans une ou plusieurs images"
            }

        # Comparer les visages
        face_distance = face_recognition.face_distance([profile_face_encoding], current_face_encoding)[0]
        threshold = 0.6  # Seuil de similarité (ajustable)

        return {
            "verified": face_distance < threshold,
            "confidence": float(1 - face_distance)
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    return {"status": "healthy"} 