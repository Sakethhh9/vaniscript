"""
audio_utils.py
Handles audio normalisation: any format → 16 kHz mono WAV temp file.
"""

import os
import tempfile
import logging
from pydub import AudioSegment

logger = logging.getLogger(__name__)

MAX_FILE_BYTES = 100 * 1024 * 1024   # 100 MB MAX SIZE OF AUDIO FILE

TARGET_SAMPLE_RATE = 16_000
TARGET_CHANNELS    = 1               

def normalize_audio(audio_bytes: bytes, original_filename: str = "audio.wav") -> str:
    if len(audio_bytes) > MAX_FILE_BYTES:
        raise ValueError(f"File too large ({len(audio_bytes)/1024/1024:.1f} MB). Max 100 MB.")

    ext = _infer_extension(original_filename)

    with tempfile.NamedTemporaryFile(delete=False, suffix=f".{ext}") as tmp_in:
        tmp_in.write(audio_bytes)
        tmp_in_path = tmp_in.name

    try:
        audio = AudioSegment.from_file(tmp_in_path)
        audio = audio.set_channels(TARGET_CHANNELS)
        audio = audio.set_frame_rate(TARGET_SAMPLE_RATE)

        with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as tmp_out:
            tmp_out_path = tmp_out.name

        audio.export(tmp_out_path, format="wav")
        logger.info(
            f"Normalised audio: {len(audio_bytes)/1024:.1f} KB → "
            f"{os.path.getsize(tmp_out_path)/1024:.1f} KB WAV "
            f"({TARGET_SAMPLE_RATE} Hz mono)"
        )
        return tmp_out_path

    except Exception as exc:
        raise RuntimeError(f"Audio decoding failed: {exc}") from exc

    finally:
        if os.path.exists(tmp_in_path):
            os.unlink(tmp_in_path)


def _infer_extension(filename: str) -> str:
    _, ext = os.path.splitext(filename)
    ext = ext.lower().lstrip(".")
    supported = {"wav", "mp3", "ogg", "m4a", "webm", "flac", "aac", "wma", "opus"}
    return ext if ext in supported else "wav"

