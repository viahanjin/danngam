from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.routers import auth

app = FastAPI(title=settings.PROJECT_NAME)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# 헬스 체크 엔드포인트
@app.get("/health")
async def health_check():
    return {"status": "ok"}


# API v1 라우터 등록
app.include_router(auth.router, prefix=settings.API_V1_STR)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
