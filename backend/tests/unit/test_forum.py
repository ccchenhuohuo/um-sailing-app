"""
Forum 模块测试
测试 /api/forum 下的端点
"""
import pytest
from fastapi import status


# ===== 标签管理测试 =====

class TestTagsList:
    """测试获取标签列表端点 GET /api/forum/tags"""

    def test_get_tags(self, client, auth_headers, test_tag):
        """测试获取标签列表"""
        response = client.get("/api/forum/tags", headers=auth_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert isinstance(data, list)
        assert len(data) > 0


class TestTagsCreate:
    """测试创建标签端点 POST /api/forum/tags"""

    def test_create_tag_admin(self, client, admin_headers):
        """测试管理员创建标签"""
        response = client.post(
            "/api/forum/tags?name=新标签",
            headers=admin_headers
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["name"] == "新标签"

    def test_create_tag_exists(self, client, admin_headers, test_tag):
        """测试创建已存在的标签"""
        response = client.post(
            f"/api/forum/tags?name={test_tag.name}",
            headers=admin_headers
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "标签已存在" in response.json()["detail"]

    def test_create_tag_no_permission(self, client, auth_headers):
        """测试普通用户无权限"""
        response = client.post("/api/forum/tags?name=新标签", headers=auth_headers)
        assert response.status_code == status.HTTP_403_FORBIDDEN


# ===== 帖子管理测试 =====

class TestPostsList:
    """测试获取帖子列表端点 GET /api/forum/posts"""

    def test_get_posts(self, client, auth_headers, test_post):
        """测试获取帖子列表"""
        response = client.get("/api/forum/posts", headers=auth_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert isinstance(data, list)
        assert len(data) > 0

    def test_get_posts_by_tag(self, client, auth_headers, test_post):
        """测试按标签筛选"""
        response = client.get(
            f"/api/forum/posts?tag_id={test_post.tag_id}",
            headers=auth_headers
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert all(post.get("tag_id") == test_post.tag_id for post in data)


class TestPostsCreate:
    """测试创建帖子端点 POST /api/forum/posts"""

    def test_create_post(self, client, auth_headers, test_tag):
        """测试创建帖子"""
        response = client.post(
            "/api/forum/posts",
            headers=auth_headers,
            json={
                "title": "新帖子标题",
                "content": "帖子内容",
                "tag_id": test_tag.id
            }
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["title"] == "新帖子标题"


class TestPostsDetail:
    """测试帖子详情端点"""

    def test_get_post(self, client, auth_headers, test_post):
        """测试获取帖子详情"""
        response = client.get(f"/api/forum/posts/{test_post.id}", headers=auth_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["title"] == test_post.title

    def test_get_post_not_found(self, client, auth_headers):
        """测试帖子不存在"""
        response = client.get("/api/forum/posts/99999", headers=auth_headers)
        assert response.status_code == status.HTTP_404_NOT_FOUND

    def test_update_post_owner(self, client, auth_headers, test_post):
        """测试帖子所有者修改"""
        response = client.put(
            f"/api/forum/posts/{test_post.id}",
            headers=auth_headers,
            json={"title": "修改后的标题"}
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["title"] == "修改后的标题"

    def test_update_post_admin(self, client, admin_headers, test_post):
        """测试管理员修改帖子"""
        response = client.put(
            f"/api/forum/posts/{test_post.id}",
            headers=admin_headers,
            json={"title": "管理员修改的标题"}
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["title"] == "管理员修改的标题"

    def test_update_post_no_permission(self, client, auth_headers, test_post, db_session):
        """测试无权限修改他人帖子"""
        # 创建一个新用户
        from app.models.user import User, UserRole
        from app.utils.security import hash_password
        new_user = User(
            username="otheruser",
            password_hash=hash_password("password"),
            email="other@example.com",
            role=UserRole.USER
        )
        db_session.add(new_user)
        db_session.commit()

        # 用新用户的 token
        from app.utils.security import create_access_token
        from datetime import timedelta
        from app.config import settings
        access_token = create_access_token(
            data={"sub": new_user.username, "user_id": new_user.id, "role": new_user.role.value},
            expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        )
        headers = {"Authorization": f"Bearer {access_token}"}

        response = client.put(
            f"/api/forum/posts/{test_post.id}",
            headers=headers,
            json={"title": "修改后的标题"}
        )
        assert response.status_code == status.HTTP_403_FORBIDDEN

    def test_delete_post_owner(self, client, auth_headers, test_post):
        """测试帖子所有者删除"""
        response = client.delete(f"/api/forum/posts/{test_post.id}", headers=auth_headers)
        assert response.status_code == status.HTTP_200_OK
        assert "删除成功" in response.json()["message"]


# ===== 评论管理测试 =====

class TestCommentsList:
    """测试获取评论列表端点 GET /api/forum/posts/{post_id}/comments"""

    def test_get_comments(self, client, auth_headers, test_post, test_comment):
        """测试获取评论列表"""
        response = client.get(
            f"/api/forum/posts/{test_post.id}/comments",
            headers=auth_headers
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert isinstance(data, list)
        assert len(data) > 0


class TestCommentsCreate:
    """测试创建评论端点 POST /api/forum/posts/{post_id}/comments"""

    def test_create_comment(self, client, auth_headers, test_post):
        """测试创建评论"""
        response = client.post(
            f"/api/forum/posts/{test_post.id}/comments",
            headers=auth_headers,
            json={"content": "新评论内容"}
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["content"] == "新评论内容"

    def test_create_comment_post_not_found(self, client, auth_headers):
        """测试帖子不存在"""
        response = client.post(
            "/api/forum/posts/99999/comments",
            headers=auth_headers,
            json={"content": "评论内容"}
        )
        assert response.status_code == status.HTTP_404_NOT_FOUND


class TestCommentsDelete:
    """测试删除评论端点 DELETE /api/forum/comments/{comment_id}"""

    def test_delete_comment_owner(self, client, auth_headers, test_comment):
        """测试评论所有者删除"""
        response = client.delete(
            f"/api/forum/comments/{test_comment.id}",
            headers=auth_headers
        )
        assert response.status_code == status.HTTP_200_OK
        assert "删除成功" in response.json()["message"]

    def test_delete_comment_admin(self, client, admin_headers, test_comment, db_session):
        """测试管理员删除评论"""
        # 创建一个新评论
        from app.models.user import User, UserRole
        from app.utils.security import hash_password
        new_user = User(
            username="commentowner",
            password_hash=hash_password("password"),
            email="commentowner@example.com",
            role=UserRole.USER
        )
        db_session.add(new_user)
        db_session.commit()

        from app.models.forum import Comment
        comment = Comment(
            content="其他用户的评论",
            post_id=test_comment.post_id,
            user_id=new_user.id
        )
        db_session.add(comment)
        db_session.commit()
        db_session.refresh(comment)

        response = client.delete(
            f"/api/forum/comments/{comment.id}",
            headers=admin_headers
        )
        assert response.status_code == status.HTTP_200_OK

    def test_delete_comment_no_permission(self, client, auth_headers, test_comment, db_session):
        """测试无权限删除他人评论"""
        # 创建一个新用户
        from app.models.user import User, UserRole
        from app.utils.security import hash_password
        new_user = User(
            username="otheruser2",
            password_hash=hash_password("password"),
            email="otheruser2@example.com",
            role=UserRole.USER
        )
        db_session.add(new_user)
        db_session.commit()

        from app.models.forum import Comment
        comment = Comment(
            content="其他用户的评论",
            post_id=test_comment.post_id,
            user_id=new_user.id
        )
        db_session.add(comment)
        db_session.commit()
        db_session.refresh(comment)

        # 用新用户的 token
        from app.utils.security import create_access_token
        from datetime import timedelta
        from app.config import settings
        access_token = create_access_token(
            data={"sub": new_user.username, "user_id": new_user.id, "role": new_user.role.value},
            expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        )
        headers = {"Authorization": f"Bearer {access_token}"}

        response = client.delete(
            f"/api/forum/comments/{test_comment.id}",
            headers=headers
        )
        assert response.status_code == status.HTTP_403_FORBIDDEN
