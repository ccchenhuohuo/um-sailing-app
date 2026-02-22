import logging
from decimal import Decimal
from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.finance import Finance, FinanceType
from app.models.user import User, UserRole
from app.routers.deps import get_current_user, get_current_admin
from app.schemas.finance import FinanceCreate, FinanceResponse, BalanceResponse

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/finances", tags=["finances"])


@router.get("", response_model=List[FinanceResponse])
def get_finances(
    skip: int = 0,
    limit: int = 100,
    type: FinanceType = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    query = db.query(Finance)
    if type:
        query = query.filter(Finance.type == type)
    # 普通用户只能看自己的记录
    if current_user.role == UserRole.USER:
        query = query.filter(Finance.user_id == current_user.id)
    finances = query.order_by(Finance.created_at.desc()).offset(skip).limit(limit).all()
    return finances


@router.get("/balance", response_model=BalanceResponse)
def get_balance(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return BalanceResponse(total_balance=current_user.balance, user_id=current_user.id)


@router.post("", response_model=FinanceResponse)
def create_finance(
    finance_data: FinanceCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # 只有管理员可以创建财务记录
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(status_code=403, detail="需要管理员权限")

    new_finance = Finance(**finance_data.model_dump())
    db.add(new_finance)

    # 如果是收入/支出涉及用户，更新用户余额，使用行级锁
    if finance_data.user_id:
        user = db.query(User).filter(User.id == finance_data.user_id).with_for_update().first()
        if user:
            if finance_data.type == FinanceType.INCOME:
                user.balance += Decimal(str(finance_data.amount))
            else:
                if user.balance < Decimal(str(finance_data.amount)):
                    raise HTTPException(status_code=400, detail="余额不足")
                user.balance -= Decimal(str(finance_data.amount))

    try:
        db.commit()
        db.refresh(new_finance)
    except Exception as e:
        db.rollback()
        logger.error(f"创建财务记录失败: {str(e)}")
        raise HTTPException(status_code=500, detail="操作失败")
    return new_finance


@router.post("/deposit")
def deposit(
    amount: float,
    user_id: int = None,
    description: str = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin)
):
    # 验证充值金额必须大于0
    if amount <= 0:
        raise HTTPException(status_code=400, detail="充值金额必须大于0")

    # 使用行级锁防止并发充值
    if user_id:
        user = db.query(User).filter(User.id == user_id).with_for_update().first()
    else:
        user = db.query(User).filter(User.id == current_user.id).with_for_update().first()

    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")

    # 充值到账户
    user.balance += Decimal(str(amount))

    # 记录财务
    finance = Finance(
        user_id=user.id,
        type=FinanceType.INCOME,
        amount=amount,
        description=description or "账户充值"
    )
    db.add(finance)

    try:
        db.commit()
        db.refresh(user)
    except Exception as e:
        db.rollback()
        logger.error(f"充值失败: {str(e)}")
        raise HTTPException(status_code=500, detail="操作失败")
    return {"message": "充值成功", "new_balance": user.balance}


@router.get("/report")
def get_finance_report(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin)
):
    income_sum = db.query(func.sum(Finance.amount)).filter(
        Finance.type == FinanceType.INCOME
    ).scalar() or 0

    expense_sum = db.query(func.sum(Finance.amount)).filter(
        Finance.type == FinanceType.EXPENSE
    ).scalar() or 0

    transaction_count = db.query(Finance).count()

    return {
        "total_income": float(income_sum),
        "total_expense": float(expense_sum),
        "net_balance": float(income_sum) - float(expense_sum),
        "transaction_count": transaction_count
    }
