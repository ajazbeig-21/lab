from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello, FastAPI is running in Docker!"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}

