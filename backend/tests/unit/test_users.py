"""
Users 模块测试
测试 /api/users 下的端点
"""
import pytest
from fastapi import status


class TestUsersList:
    """测试获取用户列表端点 /api/users"""

    def test_get_users_admin(self, client, admin_headers):
        """测试管理员获取用户列表"""
        response = client.get("/api/users", headers=admin_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert isinstance(data, list)
        assert len(data) > 0

    def test_get_users_no_permission(self, client, auth_headers):
        """测试普通用户无权限"""
        response = client.get("/api/users", headers=auth_headers)
        assert response.status_code == status.HTTP_403_FORBIDDEN

    def test_get_users_no_token(self, client):
        """测试无 token"""
        response = client.get("/api/users")
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


class TestUsersMe:
    """测试获取本人信息端点 /api/users/me"""

    def test_get_my_info(self, client, auth_headers):
        """测试获取本人信息"""
        response = client.get("/api/users/me", headers=auth_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["username"] == "testuser"

    def test_get_my_info_no_token(self, client):
        """测试无 token"""
        response = client.get("/api/users/me")
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


class TestUsersDetail:
    """测试单个用户 CRUD 端点 /api/users/{user_id}"""

    def test_get_user_by_id(self, client, auth_headers, test_user):
        """测试获取指定用户信息"""
        response = client.get(f"/api/users/{test_user.id}", headers=auth_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["username"] == test_user.username

    def test_get_user_not_found(self, client, auth_headers):
        """测试用户不存在"""
        response = client.get("/api/users/99999", headers=auth_headers)
        assert response.status_code == status.HTTP_404_NOT_FOUND
        assert "用户不存在" in response.json()["detail"]

    def test_update_user_self(self, client, auth_headers, test_user):
        """测试本人修改信息"""
        response = client.put(
            f"/api/users/{test_user.id}",
            headers=auth_headers,
            json={"phone": "1111111111"}
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["phone"] == "1111111111"

    def test_update_user_other(self, client, auth_headers, admin_user):
        """测试修改他人信息（管理员权限）"""
        response = client.put(
            f"/api/users/{admin_user.id}",
            headers=auth_headers,
            json={"phone": "2222222222"}
        )
        assert response.status_code == status.HTTP_403_FORBIDDEN

    def test_update_user_admin_permission(self, client, admin_headers, test_user):
        """测试管理员修改他人都信息"""
        response = client.put(
            f"/api/users/{test_user.id}",
            headers=admin_headers,
            json={"phone": "3333333333"}
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["phone"] == "3333333333"

    def test_delete_user_admin(self, client, admin_headers, test_user):
        """测试管理员删除用户"""
        response = client.delete(f"/api/users/{test_user.id}", headers=admin_headers)
        assert response.status_code == status.HTTP_200_OK
        assert "删除成功" in response.json()["message"]

    def test_delete_user_no_permission(self, client, auth_headers, admin_user):
        """测试普通用户删除他人"""
        response = client.delete(f"/api/users/{admin_user.id}", headers=auth_headers)
        assert response.status_code == status.HTTP_403_FORBIDDEN

    def test_delete_user_not_found(self, client, admin_headers):
        """测试删除不存在的用户"""
        response = client.delete("/api/users/99999", headers=admin_headers)
        assert response.status_code == status.HTTP_404_NOT_FOUND


class TestUsersBalance:
    """测试余额管理端点 /api/users/{user_id}/balance"""

    def test_update_balance_admin(self, client, admin_headers, test_user):
        """测试管理员修改余额"""
        original_balance = float(test_user.balance)
        response = client.post(
            f"/api/users/{test_user.id}/balance?amount=50.0",
            headers=admin_headers
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["new_balance"] == original_balance + 50.0

    def test_update_balance_no_permission(self, client, auth_headers, test_user):
        """测试普通用户修改余额"""
        response = client.post(
            f"/api/users/{test_user.id}/balance?amount=50.0",
            headers=auth_headers
        )
        assert response.status_code == status.HTTP_403_FORBIDDEN

    def test_update_balance_user_not_found(self, client, admin_headers):
        """测试修改不存在的用户余额"""
        response = client.post(
            "/api/users/99999/balance?amount=50.0",
            headers=admin_headers
        )
        assert response.status_code == status.HTTP_404_NOT_FOUND
