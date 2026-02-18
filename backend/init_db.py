"""
初始化数据库脚本
运行此脚本创建所有表并添加初始数据
"""
from app.database import engine, Base
from app.models import *
from app.models.user import UserRole
from app.utils.security import hash_password
from sqlalchemy.orm import Session

# 导入所有模型以确保它们被注册
import app.models.user
import app.models.activity
import app.models.boat
import app.models.finance
import app.models.notice
import app.models.forum
import app.models.signup


def init_db():
    # 创建所有表
    Base.metadata.create_all(bind=engine)
    print("数据库表创建完成")


def create_default_admin():
    from app.database import SessionLocal
    from app.models.user import User

    db = SessionLocal()
    try:
        # 检查是否已存在管理员
        admin = db.query(User).filter(User.username == "admin").first()
        if not admin:
            admin = User(
                username="admin",
                password_hash=hash_password("admin123"),
                email="admin@uma.edu.mo",
                phone="+85312345678",
                role=UserRole.ADMIN,
                balance=0.00
            )
            db.add(admin)
            db.commit()
            print("默认管理员账户已创建: admin / admin123")
        else:
            print("管理员账户已存在")
    finally:
        db.close()


def create_default_tags():
    from app.database import SessionLocal
    from app.models.forum import Tag

    db = SessionLocal()
    try:
        default_tags = ["闲聊", "经验分享", "技术讨论", "活动公告", "二手交易", "其他"]
        for tag_name in default_tags:
            existing = db.query(Tag).filter(Tag.name == tag_name).first()
            if not existing:
                tag = Tag(name=tag_name)
                db.add(tag)
        db.commit()
        print("默认标签已创建")
    finally:
        db.close()


if __name__ == "__main__":
    print("正在初始化数据库...")
    init_db()
    create_default_admin()
    create_default_tags()
    print("初始化完成!")
