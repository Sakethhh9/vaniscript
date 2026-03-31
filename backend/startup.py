from contextlib import asynccontextmanager
from fastapi import FastAPI
import model_loader
import logging

logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    #Startup
    logger.info("=== VaniScript API starting up ===")
    model_loader.load_model("medium")
    yield
    #Shutdown
    logger.info("=== VaniScript API shutting down ===")
