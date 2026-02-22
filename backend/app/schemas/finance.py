from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from app.models.finance import FinanceType


class FinanceBase(BaseModel):
    type: FinanceType
    amount: float = Field(..., gt=0, description="金额必须大于0")
    description: Optional[str] = None
    user_id: Optional[int] = None


class FinanceCreate(FinanceBase):
    pass


class FinanceResponse(FinanceBase):
    id: int
    user_id: Optional[int] = None
    created_at: datetime

    class Config:
        from_attributes = True


class BalanceResponse(BaseModel):
    total_balance: float
    user_id: Optional[int] = None


class TransactionCreate(BaseModel):
    amount: float = Field(..., gt=0, description="金额必须大于0")
    description: str
