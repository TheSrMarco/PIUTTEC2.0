
FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt requirements-prod.txt ./

RUN pip install --no-cache-dir -r requirements-prod.txt

COPY . /app/

# Preparar archivos estaticos para Django Admin
RUN python manage.py collectstatic --noinput

# Ejecutar el servidor sin privilegios de administrador
RUN groupadd -r app && useradd --no-log-init -r -g app app \
    && mkdir -p /app/private_uploads /app/staticfiles \
    && chown -R app:app /app

USER app

EXPOSE 8000

CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "2", "--timeout", "60"]
