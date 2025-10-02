# Use official lightweight Python image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install FastAPI and Uvicorn
RUN pip install fastapi uvicorn

# Copy project files
COPY . .

# Expose port
EXPOSE 8000

# Start the server
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

