from pydantic import BaseModel
from typing import List, Optional

class CalibrationResult(BaseModel):
    reference_vector: List[float]
    message: str = "Calibration successful"

class ComparisonResult(BaseModel):
    score: float
    is_correct: bool
    message: Optional[str] = None