FROM python:3.11-slim

RUN apt-get update && apt-get install -y ffmpeg git

WORKDIR /app

COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

RUN python -c "import whisper; whisper.load_model('medium')"

COPY . .

EXPOSE 7860

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "7860"]