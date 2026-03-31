from fastapi import APIRouter
from schemas import HealthResponse
from languages import all_languages
import model_loader

router = APIRouter()


@router.get("/", summary="Root ping")
def root():
    return {"message": "VaniScript API is running", "status": "ok"}


@router.get("/health", response_model=HealthResponse, summary="Model health check")
def health():
    return HealthResponse(
        status="ok",
        model_loaded=model_loader.is_loaded(),
    )


@router.get("/languages", summary="List supported languages")
def languages():
    return {"languages": all_languages()}
