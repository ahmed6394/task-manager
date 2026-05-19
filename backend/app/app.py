from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routers import todos
from .database import Base, engine

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Todo API", description="A simple Todo API", version="0.1.0")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Health check endpoint
@app.get("/health")
async def health_check():
    return {"status": "healthy"}


# Include routers
app.include_router(todos.router)


@app.get("/")
async def read_root():
    return {"message": "Todo API - Use /docs for API documentation"}
