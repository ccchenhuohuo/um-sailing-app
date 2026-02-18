"""
Pytest 配置文件和共享 fixtures
"""
import pytest
import os
import sys
import bcrypt

# 设置测试环境变量 - 必须在导入 app 之前设置
os.environ["TESTING"] = "true"
os.environ["SECRET_KEY"] = "test-secret-key-for-testing"

# 导入相关模块
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
from typing import Generator, Dict
from fastapi.testclient import TestClient
from datetime import timedelta
from decimal import Decimal
from datetime import datetime, timedelta

# 创建自定义的 hash_password 和 verify_password 函数
def hash_password(password: str) -> str:
    """使用 bcrypt 哈希密码"""
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """验证密码"""
    try:
        return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))
    except Exception:
        return False

# 现在导入 app - database.py 会自动检测 TESTING 模式
from app.main import app
from app.database import Base, get_db

# 导入所有模型以确保它们在测试数据库中被创建
from app.models.user import User, UserRole  # noqa: F401
from app.models.activity import Activity  # noqa: F401
from app.models.signup import ActivitySignup  # noqa: F401
from app.models.boat import Boat, BoatStatus, BoatRental  # noqa: F401
from app.models.finance import Finance, FinanceType  # noqa: F401
from app.models.notice import Notice  # noqa: F401
from app.models.forum import Post, Comment, Tag  # noqa: F401
from app.utils.security import create_access_token
from app.config import settings

# 使用自定义的 hash_password
_app_hash_password = hash_password


# 测试引擎 - 使用 SQLite
TEST_DATABASE_URL = "sqlite:///:memory:"
test_engine = create_engine(
    TEST_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)


@pytest.fixture(scope="function")
def test_engine_fixture():
    """测试引擎 fixture"""
    Base.metadata.create_all(bind=test_engine)
    yield test_engine
    Base.metadata.drop_all(bind=test_engine)


@pytest.fixture(scope="function")
def db_session(test_engine_fixture) -> Generator:
    """创建测试数据库会话"""
    TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine_fixture)
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()


@pytest.fixture(scope="function")
def client(db_session) -> Generator:
    """创建测试客户端并覆盖数据库依赖"""
    def override_get_db():
        try:
            yield db_session
        finally:
            pass

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


# ===== 用户 Fixtures =====

@pytest.fixture
def test_user(db_session) -> User:
    """创建测试用户"""
    user = User(
        username="testuser",
        password_hash=_app_hash_password("password123"),
        email="testuser@example.com",
        phone="1234567890",
        role=UserRole.USER,
        balance=Decimal("100.00")
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def admin_user(db_session) -> User:
    """创建管理员用户"""
    admin = User(
        username="admin",
        password_hash=_app_hash_password("admin123"),
        email="admin@example.com",
        phone="0987654321",
        role=UserRole.ADMIN,
        balance=Decimal("500.00")
    )
    db_session.add(admin)
    db_session.commit()
    db_session.refresh(admin)
    return admin


@pytest.fixture
def user_token(test_user) -> str:
    """生成普通用户 JWT token"""
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    return create_access_token(
        data={"sub": test_user.username, "user_id": test_user.id, "role": test_user.role.value},
        expires_delta=access_token_expires
    )


@pytest.fixture
def admin_token(admin_user) -> str:
    """生成管理员 JWT token"""
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    return create_access_token(
        data={"sub": admin_user.username, "user_id": admin_user.id, "role": admin_user.role.value},
        expires_delta=access_token_expires
    )


@pytest.fixture
def auth_headers(user_token) -> Dict[str, str]:
    """普通用户认证头"""
    return {"Authorization": f"Bearer {user_token}"}


@pytest.fixture
def admin_headers(admin_token) -> Dict[str, str]:
    """管理员认证头"""
    return {"Authorization": f"Bearer {admin_token}"}


# ===== 活动 Fixtures =====

@pytest.fixture
def test_activity(db_session, test_user) -> Activity:
    """创建测试活动"""
    activity = Activity(
        title="测试帆船活动",
        description="这是一个测试活动",
        location="澳门大学",
        start_time=datetime.utcnow() + timedelta(days=7),
        end_time=datetime.utcnow() + timedelta(days=7, hours=3),
        max_participants=10,
        creator_id=test_user.id
    )
    db_session.add(activity)
    db_session.commit()
    db_session.refresh(activity)
    return activity


# ===== 船只 Fixtures =====

@pytest.fixture
def test_boat(db_session) -> Boat:
    """创建测试船只"""
    boat = Boat(
        name="测试帆船",
        type="帆船",
        description="一艘测试用船",
        status=BoatStatus.AVAILABLE,
        rental_price=Decimal("50.00")
    )
    db_session.add(boat)
    db_session.commit()
    db_session.refresh(boat)
    return boat


# ===== 公告 Fixtures =====

@pytest.fixture
def test_notice(db_session, admin_user) -> Notice:
    """创建测试公告"""
    notice = Notice(
        title="测试公告",
        content="这是测试公告内容",
        author_id=admin_user.id
    )
    db_session.add(notice)
    db_session.commit()
    db_session.refresh(notice)
    return notice


# ===== 论坛 Fixtures =====

@pytest.fixture
def test_tag(db_session) -> Tag:
    """创建测试标签"""
    tag = Tag(name="测试标签")
    db_session.add(tag)
    db_session.commit()
    db_session.refresh(tag)
    return tag


@pytest.fixture
def test_post(db_session, test_user, test_tag) -> Post:
    """创建测试帖子"""
    post = Post(
        title="测试帖子标题",
        content="这是测试帖子的内容",
        user_id=test_user.id,
        tag_id=test_tag.id
    )
    db_session.add(post)
    db_session.commit()
    db_session.refresh(post)
    return post


@pytest.fixture
def test_comment(db_session, test_user, test_post) -> Comment:
    """创建测试评论"""
    comment = Comment(
        content="这是测试评论",
        post_id=test_post.id,
        user_id=test_user.id
    )
    db_session.add(comment)
    db_session.commit()
    db_session.refresh(comment)
    return comment
