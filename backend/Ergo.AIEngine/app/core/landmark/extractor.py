import mediapipe as mp
import cv2
import numpy as np
import logging

logger = logging.getLogger("Ergo.Extractor")

class LandmarkExtractor:
    def __init__(self, static_mode=True):
        self.mp_pose = mp.solutions.pose
        self.pose = self.mp_pose.Pose(
            static_image_mode=static_mode,
            model_complexity=1,       
            enable_segmentation=False,
            min_detection_confidence=0.5
        )

    def get_landmarks(self, image_bytes: bytes):
        try:
            image_buffer_array = np.frombuffer(image_bytes, np.uint8)
            decoded_image = cv2.imdecode(image_buffer_array, cv2.IMREAD_COLOR)
            
            if decoded_image is None:
                logger.warning("Decodificación fallida: El buffer de imagen está corrupto o vacío.")
                return None

            image_rgb = cv2.cvtColor(decoded_image, cv2.COLOR_BGR2RGB)
            pose_detection_results = self.pose.process(image_rgb)

            if not pose_detection_results.pose_landmarks:
                logger.info("No se detectaron landmarks (cuerpo humano) en el frame procesado.")
                return None
            
            return pose_detection_results.pose_landmarks.landmark

        except Exception as error:
            logger.error(f"Excepción crítica en LandmarkExtractor: {error}", exc_info=True)
            return None