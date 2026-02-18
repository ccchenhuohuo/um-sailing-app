"""
Notices 模块测试
测试 /api/notices 下的端点
"""
import pytest
from fastapi import status


class TestNoticesList:
    """测试获取公告列表端点 GET /api/notices"""

    def test_get_notices(self, client, auth_headers, test_notice):
        """测试获取公告列表"""
        response = client.get("/api/notices", headers=auth_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert isinstance(data, list)
        assert len(data) > 0

    def test_get_notices_no_token(self, client):
        """测试无 token"""
        response = client.get("/api/notices")
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


class TestNoticesDetail:
    """测试公告详情端点"""

    def test_get_notice(self, client, auth_headers, test_notice):
        """测试获取公告详情"""
        response = client.get(f"/api/notices/{test_notice.id}", headers=auth_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["title"] == test_notice.title

    def test_get_notice_not_found(self, client, auth_headers):
        """测试公告不存在"""
        response = client.get("/api/notices/99999", headers=auth_headers)
        assert response.status_code == status.HTTP_404_NOT_FOUND


class TestNoticesCreate:
    """测试创建公告端点 POST /api/notices"""

    def test_create_notice_admin(self, client, admin_headers):
        """测试管理员创建公告"""
        response = client.post(
            "/api/notices",
            headers=admin_headers,
            json={
                "title": "新公告",
                "content": "公告内容"
            }
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["title"] == "新公告"

    def test_create_notice_no_permission(self, client, auth_headers):
        """测试普通用户无权限"""
        response = client.post(
            "/api/notices",
            headers=auth_headers,
            json={"title": "新公告", "content": "内容"}
        )
        assert response.status_code == status.HTTP_403_FORBIDDEN


class TestNoticesUpdate:
    """测试更新公告端点 PUT /api/notices/{id}"""

    def test_update_notice_admin(self, client, admin_headers, test_notice):
        """测试管理员更新公告"""
        response = client.put(
            f"/api/notices/{test_notice.id}",
            headers=admin_headers,
            json={"title": "修改后的公告"}
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["title"] == "修改后的公告"

    def test_update_notice_no_permission(self, client, auth_headers, test_notice):
        """测试普通用户无权限"""
        response = client.put(
            f"/api/notices/{test_notice.id}",
            headers=auth_headers,
            json={"title": "修改后的公告"}
        )
        assert response.status_code == status.HTTP_403_FORBIDDEN


class TestNoticesDelete:
    """测试删除公告端点 DELETE /api/notices/{id}"""

    def test_delete_notice_admin(self, client, admin_headers, test_notice):
        """测试管理员删除公告"""
        response = client.delete(f"/api/notices/{test_notice.id}", headers=admin_headers)
        assert response.status_code == status.HTTP_200_OK
        assert "删除成功" in response.json()["message"]

    def test_delete_notice_no_permission(self, client, auth_headers, test_notice):
        """测试普通用户无权限"""
        response = client.delete(f"/api/notices/{test_notice.id}", headers=auth_headers)
        assert response.status_code == status.HTTP_403_FORBIDDEN
