from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.schemas.notice import NoticeCreate, NoticeResponse, NoticeUpdate
from app.models.notice import Notice
from app.models.user import User, UserRole
from app.routers.deps import get_current_user, get_current_admin

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
    db.commit()
    db.refresh(new_notice)
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

    db.commit()
    db.refresh(notice)
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
    db.commit()
    return {"message": "通知删除成功"}
