from pydantic import BaseModel
from typing import Optional


class SegmentSchema(BaseModel):
    id:    int
    start: float
    end:   float
    text:  str

class TranscriptionResponse(BaseModel):
    success:              bool
    filename:             Optional[str]  = None
    source_language:      str
    detected_language:    str
    task:                 str            # "transcribe" | "translate"
    translate_to_english: bool
    text:                 str
    processing_time_s:    float
    segments:             list[SegmentSchema]
    mode:                 Optional[str]  = None
    note:                 Optional[str]  = None

class HealthResponse(BaseModel):
    status:       str
    model_loaded: bool
    version:      str = "1.0.0"

