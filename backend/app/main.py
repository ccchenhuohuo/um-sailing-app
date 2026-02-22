import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.database import engine, Base
from app.routers import (
    auth_router, users_router, activities_router,
    boats_router, finances_router, notices_router, forum_router, stats_router
)

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # 启动时创建数据库表
    Base.metadata.create_all(bind=engine)
    yield
    # 关闭时清理


app = FastAPI(
    title="UMA Sailing App API",
    description="澳门大学帆船协会移动应用后端API",
    version="1.0.0",
    lifespan=lifespan
)

# CORS配置 - 使用环境变量控制允许的域名
cors_origins = settings.CORS_ORIGINS.split(",") if settings.CORS_ORIGINS else ["*"]
# 安全验证：allow_credentials=True 时不应使用通配符
if "*" in cors_origins:
    logger.warning("CORS: allow_credentials=True 时不应使用通配符域名，已移除 *")
    cors_origins = [origin for origin in cors_origins if origin != "*"]
    if not cors_origins:
        cors_origins = ["http://localhost:3000", "http://localhost:8080"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 注册路由
app.include_router(auth_router, prefix="/api")
app.include_router(users_router, prefix="/api")
app.include_router(activities_router, prefix="/api")
app.include_router(boats_router, prefix="/api")
app.include_router(finances_router, prefix="/api")
app.include_router(notices_router, prefix="/api")
app.include_router(forum_router, prefix="/api")
app.include_router(stats_router, prefix="/api")


@app.get("/")
def root():
    return {"message": "UMA Sailing App API", "version": "1.0.0"}


@app.get("/health")
def health_check():
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=settings.HOST, port=settings.PORT, reload=settings.DEBUG)
