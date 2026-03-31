from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import transcribe, health
from startup import lifespan
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)

app = FastAPI(
    title="VaniScript Speech API",
    description="Multi-language speech-to-text with Telugu & English focus",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],          
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router, tags=["Health"])
app.include_router(transcribe.router, prefix="/transcribe", tags=["Transcription"])

