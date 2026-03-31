"""
POST /transcribe/                  — general (any language)
POST /transcribe/telugu-to-english — Telugu audio → English text (Whisper translate)
POST /transcribe/english-to-telugu — English audio → Telugu text (Whisper + Google Translate)
POST /transcribe/any-to-any        — Transcribe then translate to any target language
"""

import os
import logging

from fastapi import APIRouter, File, UploadFile, Form, HTTPException
from fastapi.responses import JSONResponse

from audio_utils import normalize_audio
from transcription_service import transcribe
from translation_service import translate_text
from languages import resolve_language_code
import model_loader

logger = logging.getLogger(__name__)
router = APIRouter()

def _guard_model():
    if not model_loader.is_loaded():
        raise HTTPException(status_code=503, detail="Model is still loading. Please try again shortly.")


async def _read_audio(file: UploadFile) -> bytes:
    data = await file.read()
    if not data:
        raise HTTPException(status_code=400, detail="Uploaded file is empty.")
    return data


def _run_transcription(audio_bytes: bytes, filename: str, lang_name: str, translate_to_english: bool) -> dict:
    """Normalise audio and run Whisper transcription."""
    try:
        lang_code = resolve_language_code(lang_name)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    wav_path = None
    try:
        wav_path = normalize_audio(audio_bytes, filename)
        return transcribe(wav_path, lang_code, translate_to_english)
    except (ValueError, RuntimeError) as e:
        raise HTTPException(status_code=422, detail=str(e))
    except Exception as e:
        logger.error(f"Transcription error: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Transcription failed: {e}")
    finally:
        if wav_path and os.path.exists(wav_path):
            os.unlink(wav_path)

@router.post("/", summary="General transcription (all languages)")
async def transcribe_general(
    file: UploadFile = File(...),
    source_language: str = Form(default="auto"),
    translate_to_english: bool = Form(default=False),
    translate_to: str = Form(default=""),   
):
    _guard_model()
    audio_bytes = await _read_audio(file)
    result = _run_transcription(audio_bytes, file.filename or "audio", source_language, translate_to_english)

    translated_text = None
    translation_note = None
    if translate_to and translate_to.lower() not in ("", "english", "auto") and not translate_to_english:
        translated_text = translate_text(result["text"], translate_to)
        if translated_text:
            translation_note = f"Text translated to {translate_to.title()} using Google Translate."
        else:
            translation_note = "Translation failed — showing original transcription."

    return JSONResponse({
        "success":              True,
        "filename":             file.filename,
        "source_language":      source_language,
        "translate_to_english": translate_to_english,
        "translated_to":        translate_to or None,
        "text":                 translated_text if translated_text else result["text"],
        "original_text":        result["text"] if translated_text else None,
        "detected_language":    result["detected_language"],
        "task":                 result["task"],
        "processing_time_s":    result["processing_time_s"],
        "segments":             result["segments"],
        "note":                 translation_note,
    })


# ---- for Telugu -> English ----

@router.post("/telugu-to-english", summary="Telugu audio → English text")
async def telugu_to_english(
    file: UploadFile = File(...),
):
    _guard_model()
    audio_bytes = await _read_audio(file)
    result = _run_transcription(audio_bytes, file.filename or "audio", "telugu", translate_to_english=True)

    return JSONResponse({
        "success":           True,
        "mode":              "Telugu → English",
        "filename":          file.filename,
        "text":              result["text"],
        "detected_language": result["detected_language"],
        "task":              result["task"],
        "processing_time_s": result["processing_time_s"],
        "segments":          result["segments"],
    })


#---- English -> Telugu----

@router.post("/english-to-telugu", summary="English audio → Telugu text")
async def english_to_telugu(
    file: UploadFile = File(...),
):
    _guard_model()
    audio_bytes = await _read_audio(file)

    result = _run_transcription(audio_bytes, file.filename or "audio", "english", translate_to_english=False)
    english_text = result["text"]

    telugu_text = translate_text(english_text, "telugu")

    if telugu_text:
        final_text   = telugu_text
        display_note = None
    else:
        final_text   = english_text
        display_note = None

    return JSONResponse({
        "success":           True,
        "mode":              "English → Telugu",
        "filename":          file.filename,
        "text":              final_text,
        "original_text":     english_text,
        "detected_language": result["detected_language"],
        "task":              "translate",
        "processing_time_s": result["processing_time_s"],
        "segments":          result["segments"],
        "note":              display_note,
    })


# ---- Any language -> Any language ----

@router.post("/any-to-any", summary="Transcribe then translate to any target language")
async def any_to_any(
    file: UploadFile = File(...),
    source_language: str = Form(default="auto"),
    target_language: str = Form(default="english"),
):
    _guard_model()
    audio_bytes = await _read_audio(file)

    # Transcribe (kept in source language)
    result = _run_transcription(audio_bytes, file.filename or "audio", source_language, translate_to_english=False)
    original_text = result["text"]

    # Translate to target
    translated = translate_text(original_text, target_language)

    if translated:
        final_text = translated
        note       = f"Transcribed from {source_language}, translated to {target_language.title()} via Google Translate."
    else:
        final_text = original_text
        note       = f"⚠ Translation to {target_language} failed — showing original transcription."

    return JSONResponse({
        "success":           True,
        "mode":              f"{source_language.title()} → {target_language.title()}",
        "filename":          file.filename,
        "text":              final_text,
        "original_text":     original_text,
        "detected_language": result["detected_language"],
        "task":              "translate",
        "processing_time_s": result["processing_time_s"],
        "segments":          result["segments"],
        "note":              note,
    })
