from sqlalchemy import Column, Integer, DateTime, Text, Enum, DECIMAL, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database import Base
import enum


class FinanceType(str, enum.Enum):
    INCOME = "income"
    EXPENSE = "expense"


class Finance(Base):
    __tablename__ = "finances"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    type = Column(Enum(FinanceType))
    amount = Column(DECIMAL(10, 2), nullable=False)
    description = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="finances")
