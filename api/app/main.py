from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.base import BaseHTTPMiddleware

from app.config import settings
from app.routers import auth, children, reasons, money, child_auth

app = FastAPI(
    title="BunnyBank API",
    version="1.0.0",
    docs_url="/docs",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class CORSEnsureMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        response = await call_next(request)
        if "access-control-allow-origin" not in response.headers:
            response.headers["access-control-allow-origin"] = request.headers.get(
                "origin", "http://localhost:5000"
            )
            response.headers["access-control-allow-credentials"] = "true"
            response.headers["access-control-allow-methods"] = "*"
            response.headers["access-control-allow-headers"] = "*"
        return response


app.add_middleware(CORSEnsureMiddleware)

app.include_router(auth.router, prefix="/api/v1")
app.include_router(children.router, prefix="/api/v1")
app.include_router(reasons.router, prefix="/api/v1")
app.include_router(money.router, prefix="/api/v1")
app.include_router(child_auth.router, prefix="/api/v1")


@app.get("/api/v1/health")
async def health():
    return {"status": "ok"}
