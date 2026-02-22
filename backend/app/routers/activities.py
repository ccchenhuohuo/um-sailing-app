import logging
from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload

from app.database import get_db
from app.models.activity import Activity
from app.models.signup import ActivitySignup
from app.models.user import User, UserRole
from app.routers.deps import get_current_user
from app.schemas.activity import (
    ActivityCreate, ActivityResponse, ActivityUpdate,
    ActivitySignupCreate, ActivitySignupResponse
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/activities", tags=["activities"])


@router.get("", response_model=List[ActivityResponse])
def get_activities(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    activities = db.query(Activity).options(
        joinedload(Activity.creator)
    ).order_by(Activity.start_time.desc()).offset(skip).limit(limit).all()
    return activities


@router.get("/{activity_id}", response_model=ActivityResponse)
def get_activity(
    activity_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    activity = db.query(Activity).filter(Activity.id == activity_id).first()
    if not activity:
        raise HTTPException(status_code=404, detail="活动不存在")
    return activity


@router.post("", response_model=ActivityResponse)
def create_activity(
    activity_data: ActivityCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # 验证结束时间必须晚于开始时间
    if activity_data.end_time <= activity_data.start_time:
        raise HTTPException(status_code=400, detail="结束时间必须晚于开始时间")

    new_activity = Activity(**activity_data.model_dump(), creator_id=current_user.id)
    db.add(new_activity)
    try:
        db.commit()
        db.refresh(new_activity)
    except Exception:
        db.rollback()
        raise HTTPException(status_code=500, detail="操作失败")
    return new_activity


@router.put("/{activity_id}", response_model=ActivityResponse)
def update_activity(
    activity_id: int,
    activity_data: ActivityUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    activity = db.query(Activity).filter(Activity.id == activity_id).first()
    if not activity:
        raise HTTPException(status_code=404, detail="活动不存在")

    # 创建者或管理员可以修改
    if activity.creator_id != current_user.id and current_user.role != UserRole.ADMIN:
        raise HTTPException(status_code=403, detail="权限不足")

    update_data = activity_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(activity, field, value)

    try:
        db.commit()
        db.refresh(activity)
    except Exception:
        db.rollback()
        raise HTTPException(status_code=500, detail="操作失败")
    return activity


@router.delete("/{activity_id}")
def delete_activity(
    activity_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    activity = db.query(Activity).filter(Activity.id == activity_id).first()
    if not activity:
        raise HTTPException(status_code=404, detail="活动不存在")

    # 创建者或管理员可以删除
    if activity.creator_id != current_user.id and current_user.role != UserRole.ADMIN:
        raise HTTPException(status_code=403, detail="权限不足")

    db.delete(activity)
    try:
        db.commit()
    except Exception:
        db.rollback()
        raise HTTPException(status_code=500, detail="操作失败")
    return {"message": "活动删除成功"}


@router.post("/signup", response_model=ActivitySignupResponse)
def signup_activity(
    signup_data: ActivitySignupCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # 使用行级锁防止并发报名超员
    activity = db.query(Activity).filter(
        Activity.id == signup_data.activity_id
    ).with_for_update().first()
    if not activity:
        raise HTTPException(status_code=404, detail="活动不存在")

    # 检查是否已报名
    existing_signup = db.query(ActivitySignup).filter(
        ActivitySignup.activity_id == signup_data.activity_id,
        ActivitySignup.user_id == current_user.id
    ).first()
    if existing_signup:
        raise HTTPException(status_code=400, detail="已报名此活动")

    # 检查人数限制（已在事务中加锁）
    signup_count = db.query(ActivitySignup).filter(ActivitySignup.activity_id == signup_data.activity_id).count()
    if activity.max_participants > 0 and signup_count >= activity.max_participants:
        raise HTTPException(status_code=400, detail="活动人数已满")

    signup = ActivitySignup(activity_id=signup_data.activity_id, user_id=current_user.id)
    db.add(signup)
    try:
        db.commit()
        db.refresh(signup)
    except Exception as e:
        db.rollback()
        logger.error(f"创建报名记录失败: {str(e)}")
        raise HTTPException(status_code=500, detail="操作失败")
    return signup


@router.post("/{activity_id}/checkin", response_model=ActivitySignupResponse)
def checkin_activity(
    activity_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    signup = db.query(ActivitySignup).filter(
        ActivitySignup.activity_id == activity_id,
        ActivitySignup.user_id == current_user.id
    ).first()

    if not signup:
        raise HTTPException(status_code=404, detail="未找到报名记录")

    signup.check_in = True
    try:
        db.commit()
        db.refresh(signup)
    except Exception:
        db.rollback()
        raise HTTPException(status_code=500, detail="操作失败")
    return signup


@router.get("/my/signups", response_model=List[ActivitySignupResponse])
def get_my_signups(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    signups = db.query(ActivitySignup).filter(ActivitySignup.user_id == current_user.id).all()
    return signups


@router.get("/{activity_id}/signups", response_model=List[ActivitySignupResponse])
def get_activity_signups(
    activity_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    activity = db.query(Activity).filter(Activity.id == activity_id).first()
    if not activity:
        raise HTTPException(status_code=404, detail="活动不存在")

    # 创建者或管理员可以查看报名列表
    if activity.creator_id != current_user.id and current_user.role != UserRole.ADMIN:
        raise HTTPException(status_code=403, detail="权限不足")

    signups = db.query(ActivitySignup).filter(ActivitySignup.activity_id == activity_id).all()
    return signups


@router.delete("/signup/{activity_id}")
def cancel_signup(
    activity_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # 先检查活动是否存在
    activity = db.query(Activity).filter(Activity.id == activity_id).first()
    if not activity:
        raise HTTPException(status_code=404, detail="活动不存在")

    signup = db.query(ActivitySignup).filter(
        ActivitySignup.activity_id == activity_id,
        ActivitySignup.user_id == current_user.id
    ).first()

    if not signup:
        raise HTTPException(status_code=404, detail="未找到报名记录")

    db.delete(signup)
    try:
        db.commit()
    except Exception:
        db.rollback()
        raise HTTPException(status_code=500, detail="操作失败")
    return {"message": "取消报名成功"}
