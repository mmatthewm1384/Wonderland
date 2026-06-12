import hashlib
import json
import os
import shutil
import subprocess
import time
import uuid
from pathlib import Path

import magic
from flask import Flask, jsonify, request, send_file
from PIL import Image
from pypdf import PdfReader, PdfWriter
from werkzeug.utils import secure_filename

app = Flask(__name__)

INPUT_DIR = Path(os.getenv("INPUT_DIR", "/tmp/cleaner/raw"))
OUTPUT_DIR = Path(os.getenv("OUTPUT_DIR", "/tmp/cleaner/safe"))
AUDIT_DIR = Path(os.getenv("AUDIT_DIR", "/tmp/cleaner/audit"))

for p in (INPUT_DIR, OUTPUT_DIR, AUDIT_DIR):
    p.mkdir(parents=True, exist_ok=True)


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def run(cmd):
    return subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)


def audit(job):
    path = AUDIT_DIR / f"{job['job_id']}.json"
    path.write_text(json.dumps(job, indent=2) + "\n")


def scrub_image(input_path: Path, output_path: Path):
    with Image.open(input_path) as img:
        img.load()
        clean = Image.new(img.mode, img.size)
        clean.putdata(list(img.getdata()))
        clean.save(output_path)


def scrub_pdf_metadata(input_path: Path, output_path: Path):
    normalized = input_path.with_suffix(".normalized.pdf")

    q = run(["qpdf", "--linearize", str(input_path), str(normalized)])
    if q.returncode != 0:
        raise RuntimeError(f"qpdf normalize failed: {q.stdout}")

    reader = PdfReader(str(normalized))
    writer = PdfWriter()

    for page in reader.pages:
        writer.add_page(page)

    writer.add_metadata({})

    with output_path.open("wb") as f:
        writer.write(f)

    run(["exiftool", "-overwrite_original", "-all=", str(output_path)])


def rasterize_pdf(input_path: Path, output_path: Path):
    page_prefix = input_path.parent / "page"
    r = run(["pdftoppm", "-png", "-r", "180", str(input_path), str(page_prefix)])
    if r.returncode != 0:
        raise RuntimeError(f"pdftoppm failed: {r.stdout}")

    images = sorted(input_path.parent.glob("page-*.png"))
    if not images:
        raise RuntimeError("pdf rasterization produced no pages")

    opened = []
    try:
        for img_path in images:
            img = Image.open(img_path).convert("RGB")
            opened.append(img.copy())

        first, rest = opened[0], opened[1:]
        first.save(output_path, save_all=True, append_images=rest)
    finally:
        for img in opened:
            img.close()


def clean_file(raw_path: Path, safe_path: Path, mime: str, mode: str):
    if mime == "application/pdf":
        if mode == "rasterize":
            rasterize_pdf(raw_path, safe_path)
            engine = "pdf-rasterize"
        else:
            scrub_pdf_metadata(raw_path, safe_path)
            engine = "pdf-qpdf-pypdf-exiftool"
    elif mime.startswith("image/"):
        scrub_image(raw_path, safe_path)
        run(["exiftool", "-overwrite_original", "-all=", str(safe_path)])
        engine = "image-pillow-exiftool"
    else:
        raise ValueError(f"unsupported file type: {mime}")

    return engine


@app.get("/healthz")
def healthz():
    return jsonify({"status": "ok", "service": "wl-document-cleaner"})


@app.post("/sanitize")
def sanitize():
    if "file" not in request.files:
        return jsonify({"error": "missing file"}), 400

    mode = request.form.get("mode", "metadata")
    if mode not in {"metadata", "rasterize"}:
        return jsonify({"error": "invalid mode"}), 400

    upload = request.files["file"]
    original = secure_filename(upload.filename or "input.bin")

    job_id = str(uuid.uuid4())
    work = INPUT_DIR / job_id
    work.mkdir(parents=True, exist_ok=True)

    raw_path = work / original
    safe_path = OUTPUT_DIR / f"{job_id}-clean-{original}"

    job = {
        "id": "document-cleaner-audit-v4",
        "job_id": job_id,
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
        "filename": original,
        "mode": mode,
        "result": "FAIL"
    }

    try:
        upload.save(raw_path)

        mime = magic.from_file(str(raw_path), mime=True)
        job["mime"] = mime
        job["input_sha256"] = sha256(raw_path)

        engine = clean_file(raw_path, safe_path, mime, mode)

        if not safe_path.exists() or safe_path.stat().st_size == 0:
            raise RuntimeError("sanitized output missing or empty")

        job["engine"] = engine
        job["output_sha256"] = sha256(safe_path)
        job["output_size"] = safe_path.stat().st_size
        job["result"] = "PASS"
        audit(job)

        return send_file(str(safe_path), as_attachment=True)

    except Exception as exc:
        job["error"] = str(exc)
        audit(job)
        if safe_path.exists():
            safe_path.unlink()
        return jsonify({"error": str(exc), "job_id": job_id}), 500

    finally:
        shutil.rmtree(work, ignore_errors=True)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8788)
