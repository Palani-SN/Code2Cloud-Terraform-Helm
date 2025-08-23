## Backend Dockerfile

# Base Image
FROM python:3.11-slim AS base

# Workspace Folder
WORKDIR /app

# Install dos2unix
RUN apt-get update && apt-get install -y dos2unix

# Copy Requirements text file
COPY reqs.txt .

# Installation from PypI
RUN pip install --no-cache-dir -r reqs.txt
RUN python -m pip install --no-cache-dir uvicorn gunicorn

# Copy Source Code
COPY . .

# Convert line endings
RUN dos2unix run_fastapi.sh

# Make it executable
RUN chmod +x run_fastapi.sh

# Run As Production Server
FROM base AS production
CMD ["./run_fastapi.sh"]
