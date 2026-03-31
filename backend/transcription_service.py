import time
import logging
from typing import Optional
from model_loader import get_model

logger = logging.getLogger(__name__)


def transcribe(
    wav_path: str,
    language_code: Optional[str],
    translate_to_english: bool,
) -> dict:
    model = get_model()

    task = "translate" if translate_to_english else "transcribe"

    options = dict(
        language=language_code,  
        task=task,
        fp16=False,               
        verbose=False,
    )

    logger.info(f"Transcribing | lang={language_code or 'auto'} | task={task}")
    t0 = time.perf_counter()
    result = model.transcribe(wav_path, **options)
    elapsed = round(time.perf_counter() - t0, 2)
    logger.info(f"Done in {elapsed}s | detected={result.get('language')}")

    segments = [
        {
            "id":    seg["id"],
            "start": round(seg["start"], 2),
            "end":   round(seg["end"],   2),
            "text":  seg["text"].strip(),
        }
        for seg in result.get("segments", [])
    ]

    return {
        "text":               result["text"].strip(),
        "detected_language":  result.get("language", "unknown"),
        "task":               task,
        "processing_time_s":  elapsed,
        "segments":           segments,
    }

