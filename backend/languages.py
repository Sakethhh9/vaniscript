from typing import Optional

LANGUAGE_MAP: dict[str, Optional[str]] = {
    "auto":       None,
    "telugu":     "te",
    "english":    "en",
    "hindi":      "hi",
    "tamil":      "ta",
    "kannada":    "kn",
    "malayalam":  "ml",
    "marathi":    "mr",
    "bengali":    "bn",
    "gujarati":   "gu",
    "punjabi":    "pa",
    "odia":       "or",
    "assamese":   "as",
    "sanskrit":   "sa",
    "nepali":     "ne",
    "sinhala":    "si",
}

    
NON_LATIN_LANGUAGES = {"te", "hi", "ta", "kn", "ml", "mr", "bn", "gu", "pa", "ur", "or", "as", "sa", "ne", "si"}


def resolve_language_code(name: str) -> Optional[str]:
    """Return Whisper code for a display-name key, or raise ValueError."""
    key = name.strip().lower()
    if key not in LANGUAGE_MAP:
        raise ValueError(
            f"Unsupported language '{name}'. "
            f"Supported: {', '.join(sorted(LANGUAGE_MAP.keys()))}"
        )
    return LANGUAGE_MAP[key]



def all_languages() -> list[dict]:
    """Return a list of {code, name} dicts for the /languages endpoint."""
    return [
        {"code": code or "auto", "name": name.title()}
        for name, code in LANGUAGE_MAP.items()
    ]
