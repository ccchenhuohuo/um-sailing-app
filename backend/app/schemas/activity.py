from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from app.schemas.user import UserResponse


class ActivityBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    description: Optional[str] = Field(None, max_length=2000)
    location: Optional[str] = Field(None, max_length=200)
    start_time: datetime
    end_time: datetime
    max_participants: int = Field(0, ge=0, description="最大参与人数不能为负数")


class ActivityCreate(ActivityBase):
    pass


class ActivityUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = Field(None, max_length=2000)
    location: Optional[str] = Field(None, max_length=200)
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    max_participants: Optional[int] = None


class ActivityResponse(ActivityBase):
    id: int
    creator_id: int
    creator: Optional[UserResponse] = None
    created_at: datetime
    updated_at: datetime
    signups: list = []

    class Config:
        from_attributes = True


class ActivitySignupCreate(BaseModel):
    activity_id: int


class ActivitySignupResponse(BaseModel):
    id: int
    activity_id: int
    user_id: int
    signup_time: datetime
    check_in: bool

    class Config:
        from_attributes = True


class CheckIn(BaseModel):
    activity_id: int
    user_id: int
