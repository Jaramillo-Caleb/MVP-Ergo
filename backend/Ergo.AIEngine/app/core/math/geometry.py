import numpy as np
from scipy.spatial import distance
from core.config import settings

class VectorMath:
    @staticmethod
    def calculate_similarity(vector_list_a: list, vector_list_b: list) -> float:
        numpy_vector_a = np.array(vector_list_a)
        numpy_vector_b = np.array(vector_list_b)
        euclidean_distance = distance.euclidean(numpy_vector_a, numpy_vector_b)
        sigma_tolerance = settings.SIGMA_TOLERANCE  
        similarity_score = np.exp(-euclidean_distance / sigma_tolerance)
        
        return float(similarity_score)

    @staticmethod
    def is_posture_correct(similarity_score: float) -> bool:
        return similarity_score >= settings.SIMILARITY_THRESHOLD