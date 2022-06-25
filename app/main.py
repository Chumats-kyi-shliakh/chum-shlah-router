from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .routers import router


ORIGINS = [
    '*'
    # "http://devmaps.xyz",
    # "https://devmaps.xyz",
    # "http://localhost",
    # "http://localhost:8080",
]

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router.router, prefix="/router",)
