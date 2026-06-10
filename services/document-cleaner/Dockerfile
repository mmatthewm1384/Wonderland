FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    exiftool \
    file \
    libmagic1 \
    qpdf \
    poppler-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src ./src

EXPOSE 8024

ENTRYPOINT ["python", "src/app.py"]
