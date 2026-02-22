from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from app.models.boat import BoatStatus


class BoatBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    type: Optional[str] = Field(None, max_length=50)
    rental_price: float = Field(0.0, ge=0, description="租金不能为负数")
    description: Optional[str] = Field(None, max_length=500)


class BoatCreate(BoatBase):
    pass


class BoatUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    type: Optional[str] = Field(None, max_length=50)
    status: Optional[BoatStatus] = None
    rental_price: Optional[float] = Field(None, ge=0, description="租金不能为负数")
    description: Optional[str] = Field(None, max_length=500)
    image_url: Optional[str] = None


class BoatResponse(BoatBase):
    id: int
    status: BoatStatus
    image_url: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class BoatRentalCreate(BaseModel):
    boat_id: int


class BoatRentalResponse(BaseModel):
    id: int
    boat_id: int
    user_id: int
    rental_time: datetime
    return_time: Optional[datetime] = None
    status: str
    boat: Optional[BoatResponse] = None

    class Config:
        from_attributes = True


class BoatReturn(BaseModel):
    rental_id: int
