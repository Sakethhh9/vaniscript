import whisper
import logging

logger = logging.getLogger(__name__)
_model = None
def get_model():
    if _model is None:
        raise RuntimeError("Whisper model has not been loaded yet. Call load_model() first.")
    return _model

def load_model(name: str = "medium"):
    global _model
    if _model is not None:
        logger.info("Whisper model already loaded — skipping.")
        return _model
    logger.info(f"Loading Whisper '{name}' model… (first run downloads ~1.4 GB)")
    _model = whisper.load_model(name)
    logger.info("Whisper model loaded successfully.")
    return _model

def is_loaded() -> bool:
    return _model is not None




