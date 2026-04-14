import uvicorn
import logging
from fastapi import FastAPI
from api.routes import router as api_router

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)

logger = logging.getLogger(__name__)

app = FastAPI(
    title="Ergo.AIEngine",
    description="Microservicio de Inferencia de IA Stateless",
    version="1.0.0"
)

app.include_router(api_router, prefix="/internal")

@app.get("/")
def health_check():
    return {
        "status": "online", 
        "service": "Ergo.AIEngine",
        "version": "1.0.0"
    }

if __name__ == "__main__":
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)