from core.landmark.extractor import LandmarkExtractor
from core.normalization.normalizer import CoordNormalizer
from core.math.geometry import VectorMath

class MonitoringService:
    def __init__(self):
        self.extractor = LandmarkExtractor()
        self.normalizer = CoordNormalizer()
        self.math = VectorMath()

    def process_frame(self, image_bytes: bytes, reference_vector: list) -> dict:
        if not reference_vector or not isinstance(reference_vector, list):
             raise ValueError("El vector de referencia es inválido o está vacío.")

        landmarks = self.extractor.get_landmarks(image_bytes)
        
        if not landmarks:
            return {
                "score": 0.0,
                "is_correct": False,
                "message": "No se detectó usuario"
            }

        current_vector = self.normalizer.normalize(landmarks)
        score = self.math.calculate_similarity(current_vector, reference_vector)
        is_correct = self.math.is_posture_correct(score)

        return {
            "score": round(score, 4),
            "is_correct": is_correct,
            "message": "Postura correcta" if is_correct else "Postura incorrecta detectada"
        }