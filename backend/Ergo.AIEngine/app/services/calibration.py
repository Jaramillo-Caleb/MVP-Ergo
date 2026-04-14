import numpy as np
from typing import List
from core.landmark.extractor import LandmarkExtractor
from core.normalization.normalizer import CoordNormalizer
from core.config import settings
import logging

logger = logging.getLogger(__name__)

class CalibrationService:
    def __init__(self):
        self.extractor = LandmarkExtractor()
        self.normalizer = CoordNormalizer()
        self.min_images = settings.MIN_IMAGES_REQUIRED

    def calculate_average_vector(self, images_bytes_list: List[bytes]) -> List[float]:
        if len(images_bytes_list) < self.min_images:
            raise ValueError(f"Se requieren al menos {self.min_images} imágenes para calibrar. Recibidas: {len(images_bytes_list)}")

        valid_posture_vectors = []
        
        for image_bytes in images_bytes_list:
            landmarks = self.extractor.get_landmarks(image_bytes)
            if landmarks is None:
                logger.warning("Calibration: Frame ignorado, no se detectaron landmarks.")
                continue
            
            normalized_vector = self.normalizer.normalize(landmarks)
            valid_posture_vectors .append(normalized_vector)

        if not valid_posture_vectors:
            logger.error("Calibration Error: Ninguna imagen produjo landmarks válidos.")
            raise ValueError("No se pudo detectar una postura válida en ninguna de las imágenes.")

        vectors_matrix = np.array(valid_posture_vectors)
        average_posture_vector = np.mean(vectors_matrix, axis=0)

        logger.info(f"CALIBRACION EXITOSA. Vector generado (primeros 5 valores): {average_posture_vector.tolist()[:5]}")

        return average_posture_vector.tolist()