import cv2
import numpy as np
import face_recognition
import requests
from flask import Flask, request, jsonify
import base64
from io import BytesIO
from PIL import Image

app = Flask(__name__)

def load_image_from_base64(base64_string):
    try:
        # Décoder l'image base64
        image_data = base64.b64decode(base64_string)
        image = Image.open(BytesIO(image_data))
        return np.array(image), None
    except Exception as e:
        return None, f"Erreur lors du chargement de l'image: {str(e)}"

def load_image_from_url(url):
    try:
        response = requests.get(url)
        image = Image.open(BytesIO(response.content))
        return np.array(image), None
    except Exception as e:
        return None, f"Erreur lors du chargement de l'image: {str(e)}"

def get_face_encodings(image):
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

@app.route('/verify-face', methods=['POST'])
def verify_face():
    try:
        data = request.get_json()
        if not data or 'current_image' not in data or 'profile_image_url' not in data:
            return jsonify({"error": "Données manquantes"}), 400

        # Charger les images
        current_image, current_error = load_image_from_base64(data['current_image'])
        if current_error:
            return jsonify({"error": current_error}), 400

        profile_image, profile_error = load_image_from_url(data['profile_image_url'])
        if profile_error:
            return jsonify({"error": profile_error}), 400

        # Obtenir les encodages des visages
        current_face_encoding = get_face_encodings(current_image)
        profile_face_encoding = get_face_encodings(profile_image)

        if current_face_encoding is None or profile_face_encoding is None:
            return jsonify({
                "verified": False,
                "error": "Aucun visage détecté dans une ou plusieurs images"
            })

        # Comparer les visages
        face_distance = face_recognition.face_distance([profile_face_encoding], current_face_encoding)[0]
        threshold = 0.6  # Seuil de similarité (ajustable)

        return jsonify({
            "verified": face_distance < threshold,
            "confidence": float(1 - face_distance)
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000) 