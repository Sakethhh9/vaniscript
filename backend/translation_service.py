import logging
from typing import Optional

logger = logging.getLogger(__name__)

# Target language code map for deep-translator (Google Translate codes)
TRANSLATE_TARGET_MAP = {
    "telugu":    "te",
    "hindi":     "hi",
    "tamil":     "ta",
    "kannada":   "kn",
    "malayalam": "ml",
    "marathi":   "mr",
    "bengali":   "bn",
    "gujarati":  "gu",
    "punjabi":   "pa",
    "english":   "en",
}

def translate_text(text: str, target_language: str) -> Optional[str]:
    if not text or not text.strip():
        return text

    target_code = TRANSLATE_TARGET_MAP.get(target_language.lower())
    if not target_code:
        logger.warning(f"No translation code for '{target_language}', skipping.")
        return text
    
    try:
        from deep_translator import GoogleTranslator
        translated = GoogleTranslator(source="auto", target=target_code).translate(text)
        logger.info(f"Translated to {target_language} ({target_code}): {translated[:60]}...")
        return translated
    except Exception as e:
        logger.error(f"Translation failed: {e}")
        return None



