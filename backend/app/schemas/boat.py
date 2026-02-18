from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from app.models.boat import BoatStatus


class BoatBase(BaseModel):
    name: str
    type: Optional[str] = None
    rental_price: float = 0.0
    description: Optional[str] = None


class BoatCreate(BoatBase):
    pass


class BoatUpdate(BaseModel):
    name: Optional[str] = None
    type: Optional[str] = None
    status: Optional[BoatStatus] = None
    rental_price: Optional[float] = None
    description: Optional[str] = None
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
