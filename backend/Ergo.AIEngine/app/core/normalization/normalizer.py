import numpy as np
from core.config import settings

class CoordNormalizer:
    def normalize(self, raw_landmarks_list) -> list:
        landmarks_coordinates = [
            [raw_landmarks_list[i].x, raw_landmarks_list[i].y, raw_landmarks_list[i].z] 
            for i in settings.RELEVANT_LANDMARKS
        ]
        coordinates_array = np.array(landmarks_coordinates) 
        coordinates_mean  = np.mean(coordinates_array , axis=0)
        centered_coordinates = coordinates_array  - coordinates_mean  
        standard_deviation = np.std(centered_coordinates )
        
        if standard_deviation == 0:
            standard_deviation = 1.0
            
        normalized_coordinates = centered_coordinates / standard_deviation 
        
        return normalized_coordinates.flatten().tolist()