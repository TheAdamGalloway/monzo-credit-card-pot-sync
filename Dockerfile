# --- Stage 1: build static web assets (Tailwind CSS) ---
FROM node:23-slim AS css-builder

WORKDIR /build

COPY package.json package-lock.json ./
RUN npm ci

COPY tailwind.config.js ./
COPY app ./app

RUN npm run build-css

# --- Stage 2: runtime image ---
FROM python:3.13-slim-bookworm

WORKDIR /monzo-credit-card-pot-sync

COPY requirements.txt wsgi.py ./

RUN pip3 install -r requirements.txt

COPY app ./app

# Pull in the compiled stylesheet from the build stage so the image is
# self-contained and doesn't rely on the artifact existing in the context.
COPY --from=css-builder /build/app/static/css/dist/output.css ./app/static/css/dist/output.css

CMD ["gunicorn", "--bind", "0.0.0.0:1337", "wsgi:app"]
