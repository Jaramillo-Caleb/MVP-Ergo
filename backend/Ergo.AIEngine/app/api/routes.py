from fastapi import APIRouter, UploadFile, File, Form, HTTPException, Depends
from fastapi.concurrency import run_in_threadpool
from typing import List
import json

from models.schemas import CalibrationResult, ComparisonResult
from services.calibration import CalibrationService
from services.monitoring import MonitoringService

router = APIRouter()

def get_calibration_service() -> CalibrationService:
    return CalibrationService()

def get_monitoring_service() -> MonitoringService:
    return MonitoringService()

@router.post("/calibration", response_model=CalibrationResult)
async def calibrate_posture(
    images: List[UploadFile] = File(...),
    service: CalibrationService = Depends(get_calibration_service) 
):
    try:
        image_data_list = []
        for img in images:
            content = await img.read()
            image_data_list.append(content)

        result_vector = await run_in_threadpool(
            service.calculate_average_vector, 
            image_data_list
        )

        return {
            "reference_vector": result_vector,
            "message": "Calibración exitosa"
        }

    except ValueError as ve:
        raise HTTPException(status_code=400, detail=str(ve))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")


@router.post("/compare", response_model=ComparisonResult)
async def compare_posture(
    image: UploadFile = File(...),
    reference_vector: str = Form(...),
    service: MonitoringService = Depends(get_monitoring_service)
):
    try:
        try:
            reference_list = json.loads(reference_vector)
        except json.JSONDecodeError:
            raise ValueError("El formato del vector no es un JSON válido.")

        image_content = await image.read()
        result = await run_in_threadpool(
            service.process_frame, 
            image_content, 
            reference_list
        )
        
        return result

    except ValueError as validation_error:
        raise HTTPException(status_code=400, detail=str(validation_error))
    except Exception as error:
        raise HTTPException(status_code=500, detail=f"Error interno: {str(error)}")