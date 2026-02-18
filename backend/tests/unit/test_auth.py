"""
Auth 模块测试
测试 /api/auth 下的端点
"""
import pytest
from fastapi import status


class TestAuthRegister:
    """测试注册端点 /api/auth/register"""

    def test_register_success(self, client):
        """测试正常注册"""
        response = client.post("/api/auth/register", json={
            "username": "newuser",
            "email": "newuser@example.com",
            "password": "password123",
            "phone": "1234567890"
        })
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "access_token" in data
        assert data["user"]["username"] == "newuser"
        assert data["user"]["email"] == "newuser@example.com"

    def test_register_username_exists(self, client, test_user):
        """测试用户名已存在"""
        response = client.post("/api/auth/register", json={
            "username": test_user.username,
            "email": "another@example.com",
            "password": "password123"
        })
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "用户名已存在" in response.json()["detail"]

    def test_register_email_exists(self, client, test_user):
        """测试邮箱已注册"""
        response = client.post("/api/auth/register", json={
            "username": "anotheruser",
            "email": test_user.email,
            "password": "password123"
        })
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "邮箱已被注册" in response.json()["detail"]

    def test_register_missing_fields(self, client):
        """测试缺少必填字段"""
        response = client.post("/api/auth/register", json={
            "username": "testuser"
        })
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


class TestAuthLogin:
    """测试登录端点 /api/auth/login"""

    def test_login_success(self, client, test_user):
        """测试正常登录"""
        response = client.post("/api/auth/login", json={
            "username": "testuser",
            "password": "password123"
        })
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "access_token" in data
        assert data["user"]["username"] == "testuser"

    def test_login_wrong_username(self, client):
        """测试用户名错误"""
        response = client.post("/api/auth/login", json={
            "username": "nonexistent",
            "password": "password123"
        })
        assert response.status_code == status.HTTP_401_UNAUTHORIZED
        assert "用户名或密码错误" in response.json()["detail"]

    def test_login_wrong_password(self, client, test_user):
        """测试密码错误"""
        response = client.post("/api/auth/login", json={
            "username": test_user.username,
            "password": "wrongpassword"
        })
        assert response.status_code == status.HTTP_401_UNAUTHORIZED
        assert "用户名或密码错误" in response.json()["detail"]


class TestAuthMe:
    """测试获取当前用户信息端点 /api/auth/me"""

    def test_me_success(self, client, auth_headers):
        """测试正常获取用户信息"""
        response = client.get("/api/auth/me", headers=auth_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["username"] == "testuser"

    def test_me_no_token(self, client):
        """测试无 token"""
        response = client.get("/api/auth/me")
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_me_invalid_token(self, client):
        """测试无效 token"""
        response = client.get("/api/auth/me", headers={"Authorization": "Bearer invalid_token"})
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


class TestAuthRefresh:
    """测试刷新 token 端点 /api/auth/refresh"""

    def test_refresh_success(self, client, auth_headers):
        """测试正常刷新 token"""
        response = client.post("/api/auth/refresh", headers=auth_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "access_token" in data
        assert data["user"]["username"] == "testuser"

    def test_refresh_no_token(self, client):
        """测试无 token"""
        response = client.post("/api/auth/refresh")
        assert response.status_code == status.HTTP_401_UNAUTHORIZED
