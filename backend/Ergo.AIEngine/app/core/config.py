from typing import List
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "Ergo.AIEngine"
    VERSION: str = "1.0.0"  

    MIN_IMAGES_REQUIRED: int = 5
    SIMILARITY_THRESHOLD: float = 0.92
    SIGMA_TOLERANCE: float = 5.5
    RELEVANT_LANDMARKS: List[int] = [0, 7, 8, 11, 12] 

    class Config:
        env_file = ".env"

settings = Settings()