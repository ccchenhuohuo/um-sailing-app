import logging
from datetime import datetime
from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload

from app.database import get_db
from app.models.boat import Boat, BoatRental, BoatStatus
from app.models.user import User, UserRole
from app.routers.deps import get_current_user, get_current_admin
from app.schemas.boat import (
    BoatCreate, BoatResponse, BoatUpdate,
    BoatRentalResponse, BoatReturn
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/boats", tags=["boats"])


@router.get("", response_model=List[BoatResponse])
def get_boats(
    skip: int = 0,
    limit: int = 100,
    status: BoatStatus = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    query = db.query(Boat)
    if status:
        query = query.filter(Boat.status == status)
    boats = query.offset(skip).limit(limit).all()
    return boats


# /rentals 必须在 /{boat_id} 之前定义，避免路径冲突
@router.get("/rentals", response_model=List[BoatRentalResponse])
def get_my_rentals(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    rentals = db.query(BoatRental).filter(BoatRental.user_id == current_user.id).all()
    return rentals


@router.get("/all/rentals", response_model=List[BoatRentalResponse])
def get_all_rentals(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin)
):
    rentals = db.query(BoatRental).options(
        joinedload(BoatRental.boat)
    ).all()
    return rentals


@router.get("/{boat_id}", response_model=BoatResponse)
def get_boat(
    boat_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    boat = db.query(Boat).filter(Boat.id == boat_id).first()
    if not boat:
        raise HTTPException(status_code=404, detail="船只不存在")
    return boat


@router.post("", response_model=BoatResponse)
def create_boat(
    boat_data: BoatCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin)
):
    new_boat = Boat(**boat_data.model_dump())
    db.add(new_boat)
    try:
        db.commit()
        db.refresh(new_boat)
    except Exception as e:
        db.rollback()
        logger.error(f"创建船只失败: {str(e)}")
        raise HTTPException(status_code=500, detail="操作失败")
    return new_boat


@router.put("/{boat_id}", response_model=BoatResponse)
def update_boat(
    boat_id: int,
    boat_data: BoatUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin)
):
    boat = db.query(Boat).filter(Boat.id == boat_id).first()
    if not boat:
        raise HTTPException(status_code=404, detail="船只不存在")

    update_data = boat_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(boat, field, value)

    try:
        db.commit()
        db.refresh(boat)
    except Exception as e:
        db.rollback()
        logger.error(f"更新船只失败: {str(e)}")
        raise HTTPException(status_code=500, detail="操作失败")
    return boat


@router.delete("/{boat_id}")
def delete_boat(
    boat_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin)
):
    boat = db.query(Boat).filter(Boat.id == boat_id).first()
    if not boat:
        raise HTTPException(status_code=404, detail="船只不存在")

    try:
        db.delete(boat)
        db.commit()
    except Exception as e:
        db.rollback()
        logger.error(f"删除船只失败: {str(e)}")
        raise HTTPException(status_code=500, detail="操作失败")
    return {"message": "船只删除成功"}


@router.post("/{boat_id}/rent", response_model=BoatRentalResponse)
def rent_boat(
    boat_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # 使用 with_for_update() 添加行级锁，防止竞态条件
    boat = db.query(Boat).filter(Boat.id == boat_id).with_for_update().first()
    if not boat:
        raise HTTPException(status_code=404, detail="船只不存在")

    if boat.status != BoatStatus.AVAILABLE:
        raise HTTPException(status_code=400, detail="船只不可租借")

    # 检查用户余额
    if current_user.balance < boat.rental_price:
        raise HTTPException(status_code=400, detail="余额不足")

    # 创建租赁记录
    rental = BoatRental(
        boat_id=boat_id,
        user_id=current_user.id,
        rental_time=datetime.utcnow(),
        status="active"
    )
    db.add(rental)

    # 更新船只状态
    boat.status = BoatStatus.RENTED

    # 扣减余额
    current_user.balance -= boat.rental_price

    try:
        db.commit()
        db.refresh(rental)
    except Exception as e:
        db.rollback()
        logger.error(f"租船失败: {str(e)}")
        raise HTTPException(status_code=500, detail="操作失败")
    return rental


@router.post("/return", response_model=BoatRentalResponse)
def return_boat(
    return_data: BoatReturn,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # 使用 with_for_update() 添加行级锁，确保事务一致性
    rental = db.query(BoatRental).filter(
        BoatRental.id == return_data.rental_id,
        BoatRental.status == "active"
    ).with_for_update().first()

    if not rental:
        raise HTTPException(status_code=404, detail="未找到租赁记录")

    # 管理员可以帮任何用户归还，普通用户只能归还自己的
    if current_user.role != UserRole.ADMIN and current_user.id != rental.user_id:
        raise HTTPException(status_code=403, detail="权限不足")

    boat = db.query(Boat).filter(Boat.id == rental.boat_id).with_for_update().first()
    if not boat:
        raise HTTPException(status_code=404, detail="船只不存在")

    rental.return_time = datetime.utcnow()
    rental.status = "returned"
    boat.status = BoatStatus.AVAILABLE

    try:
        db.commit()
        db.refresh(rental)
    except Exception as e:
        db.rollback()
        logger.error(f"还船失败: {str(e)}")
        raise HTTPException(status_code=500, detail="操作失败")
    return rental
