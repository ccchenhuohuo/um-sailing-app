import logging
from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.forum import Post, Comment, Tag
from app.models.user import User, UserRole
from app.routers.deps import get_current_user, get_current_admin
from app.schemas.forum import (
    PostCreate, PostResponse, PostUpdate,
    CommentCreate, CommentResponse, TagResponse
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/forum", tags=["forum"])


# ===== 标签管理 =====
@router.get("/tags", response_model=List[TagResponse])
def get_tags(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    tags = db.query(Tag).all()
    return tags


@router.post("/tags", response_model=TagResponse)
def create_tag(name: str, db: Session = Depends(get_db), current_user: User = Depends(get_current_admin)):
    existing_tag = db.query(Tag).filter(Tag.name == name).first()
    if existing_tag:
        raise HTTPException(status_code=400, detail="标签已存在")

    new_tag = Tag(name=name)
    db.add(new_tag)
    try:
        db.commit()
        db.refresh(new_tag)
    except Exception as e:
        db.rollback()
        logger.error(f"创建标签失败: {str(e)}")
        raise HTTPException(status_code=500, detail="操作失败")
    return new_tag


# ===== 帖子管理 =====
@router.get("/posts", response_model=List[PostResponse])
def get_posts(
    skip: int = 0,
    limit: int = 100,
    tag_id: int = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    query = db.query(Post)
    if tag_id:
        query = query.filter(Post.tag_id == tag_id)
    posts = query.order_by(Post.created_at.desc()).offset(skip).limit(limit).all()
    return posts


@router.get("/posts/{post_id}", response_model=PostResponse)
def get_post(
    post_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="帖子不存在")
    return post


@router.post("/posts", response_model=PostResponse)
def create_post(
    post_data: PostCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    new_post = Post(**post_data.model_dump(), user_id=current_user.id)
    db.add(new_post)
    try:
        db.commit()
        db.refresh(new_post)
    except Exception as e:
        db.rollback()
        logger.error(f"创建帖子失败: {str(e)}")
        raise HTTPException(status_code=500, detail="操作失败")
    return new_post


@router.put("/posts/{post_id}", response_model=PostResponse)
def update_post(
    post_id: int,
    post_data: PostUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="帖子不存在")

    if post.user_id != current_user.id and current_user.role != UserRole.ADMIN:
        raise HTTPException(status_code=403, detail="权限不足")

    update_data = post_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(post, field, value)

    try:
        db.commit()
        db.refresh(post)
    except Exception as e:
        db.rollback()
        logger.error(f"更新帖子失败: {str(e)}")
        raise HTTPException(status_code=500, detail="操作失败")
    return post


@router.delete("/posts/{post_id}")
def delete_post(
    post_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="帖子不存在")

    if post.user_id != current_user.id and current_user.role != UserRole.ADMIN:
        raise HTTPException(status_code=403, detail="权限不足")

    db.delete(post)
    try:
        db.commit()
    except Exception as e:
        db.rollback()
        logger.error(f"删除帖子失败: {str(e)}")
        raise HTTPException(status_code=500, detail="操作失败")
    return {"message": "帖子删除成功"}


# ===== 评论管理 =====
@router.get("/posts/{post_id}/comments", response_model=List[CommentResponse])
def get_comments(
    post_id: int,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    comments = db.query(Comment).filter(Comment.post_id == post_id).offset(skip).limit(limit).all()
    return comments


@router.post("/posts/{post_id}/comments", response_model=CommentResponse)
def create_comment(
    post_id: int,
    comment_data: CommentCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # 验证帖子存在
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="帖子不存在")

    comment_dict = comment_data.model_dump(exclude={'post_id'})
    new_comment = Comment(**comment_dict, post_id=post_id, user_id=current_user.id)
    db.add(new_comment)
    try:
        db.commit()
        db.refresh(new_comment)
    except Exception as e:
        db.rollback()
        logger.error(f"创建评论失败: {str(e)}")
        raise HTTPException(status_code=500, detail="操作失败")
    return new_comment


@router.delete("/comments/{comment_id}")
def delete_comment(
    comment_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    comment = db.query(Comment).filter(Comment.id == comment_id).first()
    if not comment:
        raise HTTPException(status_code=404, detail="评论不存在")

    # 评论所有者或管理员可以删除
    if comment.user_id != current_user.id and current_user.role != UserRole.ADMIN:
        raise HTTPException(status_code=403, detail="权限不足")

    db.delete(comment)
    try:
        db.commit()
    except Exception as e:
        db.rollback()
        logger.error(f"删除评论失败: {str(e)}")
        raise HTTPException(status_code=500, detail="操作失败")
    return {"message": "评论删除成功"}
