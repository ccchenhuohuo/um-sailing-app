from pydantic_settings import BaseSettings
from typing import Optional
from functools import lru_cache
import logging

logger = logging.getLogger(__name__)

# 开发环境默认密钥 - 仅用于开发环境
DEV_SECRET_KEY = "dev-secret-key-do-not-use-in-production-please-set-env-var"


class Settings(BaseSettings):
    # Database
    DB_HOST: str = "localhost"
    DB_PORT: int = 3306
    DB_NAME: str = "uma_sailing"
    DB_USER: str = "root"
    DB_PASSWORD: str = "password"

    # JWT - 生产环境必须通过环境变量配置
    SECRET_KEY: str = DEV_SECRET_KEY
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # Server
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    DEBUG: bool = True

    # CORS - 使用环境变量控制
    CORS_ORIGINS: str = "*"

    # Email (optional)
    SMTP_HOST: Optional[str] = None
    SMTP_PORT: Optional[int] = None
    SMTP_USER: Optional[str] = None
    SMTP_PASSWORD: Optional[str] = None

    class Config:
        env_file = ".env"
        case_sensitive = True

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        # 如果使用默认密钥，发出警告
        if self.SECRET_KEY == DEV_SECRET_KEY:
            logger.warning("使用默认 SECRET_KEY，生产环境请设置 SECRET_KEY 环境变量")
        # 如果使用默认数据库密码，发出警告
        if self.DB_PASSWORD == "password":
            logger.warning("使用默认数据库密码，请设置 DB_PASSWORD 环境变量")


@lru_cache()
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
