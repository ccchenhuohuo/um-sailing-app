import logging
from decimal import Decimal
from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.user import User, UserRole
from app.routers.deps import get_current_user, get_current_admin
from app.schemas.user import UserResponse, UserUpdate

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/users", tags=["users"])


@router.get("", response_model=List[UserResponse])
def get_users(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin)
):
    users = db.query(User).offset(skip).limit(limit).all()
    return users


@router.get("/me", response_model=UserResponse)
def get_my_info(current_user: User = Depends(get_current_user)):
    return current_user


@router.get("/{user_id}", response_model=UserResponse)
def get_user(user_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    # 只有管理员或本人可以查看用户信息
    if current_user.id != user_id and current_user.role != UserRole.ADMIN:
        raise HTTPException(status_code=403, detail="权限不足")
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")
    return user


@router.put("/{user_id}", response_model=UserResponse)
def update_user(
    user_id: int,
    user_data: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # 只有管理员或本人可以修改
    if current_user.id != user_id and current_user.role != UserRole.ADMIN:
        raise HTTPException(status_code=403, detail="权限不足")

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")

    update_data = user_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(user, field, value)

    try:
        db.commit()
        db.refresh(user)
    except Exception as e:
        db.rollback()
        logger.error(f"操作失败: {str(e)}")
        raise HTTPException(status_code=500, detail="操作失败")
    return user


@router.delete("/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_admin)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")

    try:
        db.delete(user)
        db.commit()
    except Exception as e:
        db.rollback()
        logger.error(f"操作失败: {str(e)}")
        raise HTTPException(status_code=500, detail="操作失败")
    return {"message": "用户删除成功"}


@router.post("/{user_id}/balance")
def update_balance(
    user_id: int,
    amount: float,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin)
):
    # 验证金额不能为0
    if amount == 0:
        raise HTTPException(status_code=400, detail="金额不能为零")

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")

    user.balance += Decimal(str(amount))
    try:
        db.commit()
        db.refresh(user)
    except Exception as e:
        db.rollback()
        logger.error(f"操作失败: {str(e)}")
        raise HTTPException(status_code=500, detail="操作失败")
    return {"message": "余额更新成功", "new_balance": user.balance}
