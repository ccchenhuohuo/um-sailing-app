import logging
from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.notice import Notice
from app.models.user import User
from app.routers.deps import get_current_user, get_current_admin
from app.schemas.notice import NoticeCreate, NoticeResponse, NoticeUpdate

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/notices", tags=["notices"])


@router.get("", response_model=List[NoticeResponse])
def get_notices(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    notices = db.query(Notice).order_by(Notice.created_at.desc()).offset(skip).limit(limit).all()
    return notices


@router.get("/{notice_id}", response_model=NoticeResponse)
def get_notice(
    notice_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    notice = db.query(Notice).filter(Notice.id == notice_id).first()
    if not notice:
        raise HTTPException(status_code=404, detail="通知不存在")
    return notice


@router.post("", response_model=NoticeResponse)
def create_notice(
    notice_data: NoticeCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin)
):
    new_notice = Notice(**notice_data.model_dump(), author_id=current_user.id)
    db.add(new_notice)
    try:
        db.commit()
        db.refresh(new_notice)
    except Exception as e:
        db.rollback()
        logger.error(f"创建通知失败: {str(e)}")
        raise HTTPException(status_code=500, detail="操作失败")
    return new_notice


@router.put("/{notice_id}", response_model=NoticeResponse)
def update_notice(
    notice_id: int,
    notice_data: NoticeUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin)
):
    notice = db.query(Notice).filter(Notice.id == notice_id).first()
    if not notice:
        raise HTTPException(status_code=404, detail="通知不存在")

    update_data = notice_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(notice, field, value)

    try:
        db.commit()
        db.refresh(notice)
    except Exception as e:
        db.rollback()
        logger.error(f"更新通知失败: {str(e)}")
        raise HTTPException(status_code=500, detail="操作失败")
    return notice


@router.delete("/{notice_id}")
def delete_notice(
    notice_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin)
):
    notice = db.query(Notice).filter(Notice.id == notice_id).first()
    if not notice:
        raise HTTPException(status_code=404, detail="通知不存在")

    db.delete(notice)
    try:
        db.commit()
    except Exception as e:
        db.rollback()
        logger.error(f"删除通知失败: {str(e)}")
        raise HTTPException(status_code=500, detail="操作失败")
    return {"message": "通知删除成功"}
