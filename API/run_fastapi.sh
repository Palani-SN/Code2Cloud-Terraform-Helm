#!/usr/bin/env bash
gunicorn -w 4 -k uvicorn.workers.UvicornWorker backend:app -b 0.0.0.0:8000
echo "FastAPI started at http://localhost:8000/ (BACKEND - connected to host via bridge network)"