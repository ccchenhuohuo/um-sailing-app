from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class TagBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=50)


class TagResponse(TagBase):
    id: int

    class Config:
        from_attributes = True


class PostBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    content: str = Field(..., min_length=1, max_length=10000)
    tag_id: Optional[int] = None


class PostCreate(PostBase):
    pass


class PostUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    content: Optional[str] = Field(None, min_length=1, max_length=10000)
    tag_id: Optional[int] = None


class PostResponse(PostBase):
    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class CommentBase(BaseModel):
    content: str = Field(..., min_length=1, max_length=2000)


class CommentCreate(CommentBase):
    post_id: Optional[int] = None


class CommentResponse(CommentBase):
    id: int
    post_id: int
    user_id: int
    created_at: datetime

    class Config:
        from_attributes = True
