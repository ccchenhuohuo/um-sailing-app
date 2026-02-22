from sqlalchemy import Column, Integer, DateTime, Text, DECIMAL, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from sqlalchemy.types import TypeDecorator, String
from app.database import Base
import enum


class BoatStatus(str, enum.Enum):
    AVAILABLE = "available"
    RENTED = "rented"
    MAINTENANCE = "maintenance"


class CaseInsensitiveEnum(TypeDecorator):
    """支持大小写不敏感的枚举类型"""
    impl = String
    cache_ok = True

    def __init__(self, enum_class, **kwargs):
        self.enum_class = enum_class
        super().__init__(**kwargs)

    def load_dialect_impl(self, dialect):
        return dialect.type_descriptor(String(50))

    def process_bind_param(self, value, dialect):
        if value is None:
            return None
        return value.value

    def process_result_value(self, value, dialect):
        if value is None:
            return None
        # 大小写不敏感处理
        value_lower = value.lower()
        for member in self.enum_class:
            if member.value.lower() == value_lower:
                return member
        # 如果找不到匹配的枚举值，返回默认值
        return self.enum_class.AVAILABLE

    def __repr__(self):
        return f"CaseInsensitiveEnum({self.enum_class.__name__})"


class Boat(Base):
    __tablename__ = "boats"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), nullable=False)
    type = Column(String(50))
    status = Column(CaseInsensitiveEnum(BoatStatus), default=BoatStatus.AVAILABLE)
    rental_price = Column(DECIMAL(10, 2), default=0.00)
    image_url = Column(String(255))
    description = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    rentals = relationship("BoatRental", back_populates="boat")


class BoatRental(Base):
    __tablename__ = "boats_rentals"

    id = Column(Integer, primary_key=True, index=True)
    boat_id = Column(Integer, ForeignKey("boats.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    rental_time = Column(DateTime(timezone=True), nullable=False)
    return_time = Column(DateTime(timezone=True))
    status = Column(String(20), default="active")

    boat = relationship("Boat", back_populates="rentals")
    user = relationship("User")
