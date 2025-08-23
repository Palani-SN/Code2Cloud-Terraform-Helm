#!/usr/bin/env bash
gunicorn -w 4 'frontend:app' -b 0.0.0.0:5000
echo "Flask started at http://localhost:5000/ (FRONTEND - connected to host via bridge network)"