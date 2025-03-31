FROM python:3.9-slim
RUN useradd --create-home --shell /bin/bash appuser
WORKDIR /app
COPY . /app
RUN chown -R appuser:appuser /app
USER appuser
EXPOSE 8080
CMD ["python", "simple_server.py"]
