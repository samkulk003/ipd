from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Dict, List

app = FastAPI()

# Data storage
received_data: List[Dict] = []

class SentenceData(BaseModel):
    totalAttempts: int
    timeTaken: int
    attemptsPerPunctuation: Dict

@app.post("/process-input/")
async def process_input(data: SentenceData):
    # Convert model to dict and store in the list
    received_data.append(data.dict())
    return {"message": "Data received successfully", "received_data": data}

@app.get("/data/")
async def get_data():
    return {"received_data": received_data}