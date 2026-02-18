"""
Boats 模块测试
测试 /api/boats 下的端点
"""
import pytest
from fastapi import status
from decimal import Decimal


class TestBoatsList:
    """测试获取船只列表端点 GET /api/boats"""

    def test_get_boats(self, client, auth_headers, test_boat):
        """测试获取船只列表"""
        response = client.get("/api/boats", headers=auth_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert isinstance(data, list)
        assert len(data) > 0

    def test_get_boats_by_status(self, client, auth_headers, test_boat):
        """测试按状态筛选船只"""
        response = client.get("/api/boats?status=available", headers=auth_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert all(boat["status"] == "available" for boat in data)

    def test_get_boats_no_token(self, client):
        """测试无 token"""
        response = client.get("/api/boats")
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


class TestBoatsCreate:
    """测试创建船只端点 POST /api/boats"""

    def test_create_boat_admin(self, client, admin_headers):
        """测试管理员创建船只"""
        response = client.post(
            "/api/boats",
            headers=admin_headers,
            json={
                "name": "新船只",
                "type": "帆船",
                "description": "测试船只",
                "status": "available",
                "rental_price": 100.0
            }
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["name"] == "新船只"

    def test_create_boat_no_permission(self, client, auth_headers):
        """测试普通用户无权限"""
        response = client.post(
            "/api/boats",
            headers=auth_headers,
            json={"name": "新船只", "type": "帆船"}
        )
        assert response.status_code == status.HTTP_403_FORBIDDEN


class TestBoatsDetail:
    """测试船只详情端点"""

    def test_get_boat(self, client, auth_headers, test_boat):
        """测试获取船只详情"""
        response = client.get(f"/api/boats/{test_boat.id}", headers=auth_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["name"] == test_boat.name

    def test_get_boat_not_found(self, client, auth_headers):
        """测试船只不存在"""
        response = client.get("/api/boats/99999", headers=auth_headers)
        assert response.status_code == status.HTTP_404_NOT_FOUND

    def test_update_boat_admin(self, client, admin_headers, test_boat):
        """测试管理员修改船只"""
        response = client.put(
            f"/api/boats/{test_boat.id}",
            headers=admin_headers,
            json={"name": "修改后的船只"}
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["name"] == "修改后的船只"

    def test_update_boat_no_permission(self, client, auth_headers, test_boat):
        """测试普通用户无权限"""
        response = client.put(
            f"/api/boats/{test_boat.id}",
            headers=auth_headers,
            json={"name": "修改后的船只"}
        )
        assert response.status_code == status.HTTP_403_FORBIDDEN

    def test_delete_boat_admin(self, client, admin_headers, test_boat):
        """测试管理员删除船只"""
        response = client.delete(f"/api/boats/{test_boat.id}", headers=admin_headers)
        assert response.status_code == status.HTTP_200_OK
        assert "删除成功" in response.json()["message"]


class TestBoatsRent:
    """测试租船端点 POST /api/boats/{id}/rent"""

    def test_rent_boat_success(self, client, auth_headers, test_boat):
        """测试租船成功"""
        response = client.post(f"/api/boats/{test_boat.id}/rent", headers=auth_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["boat_id"] == test_boat.id
        assert data["status"] == "active"

    def test_rent_boat_not_found(self, client, auth_headers):
        """测试租借不存在的船只"""
        response = client.post("/api/boats/99999/rent", headers=auth_headers)
        assert response.status_code == status.HTTP_404_NOT_FOUND

    def test_rent_boat_insufficient_balance(self, client, auth_headers, test_boat, db_session, test_user):
        """测试余额不足"""
        # 修改用户余额
        test_user.balance = Decimal("0.00")
        db_session.commit()

        response = client.post(f"/api/boats/{test_boat.id}/rent", headers=auth_headers)
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "余额不足" in response.json()["detail"]


class TestBoatsReturn:
    """测试还船端点 POST /api/boats/return"""

    def test_return_boat_success(self, client, auth_headers, test_boat, db_session, test_user):
        """测试还船成功"""
        from app.models.boat import BoatRental
        from datetime import datetime

        # 先租船
        rental = BoatRental(
            boat_id=test_boat.id,
            user_id=test_user.id,
            rental_time=datetime.utcnow(),
            status="active"
        )
        db_session.add(rental)
        db_session.commit()
        db_session.refresh(rental)

        response = client.post(
            "/api/boats/return",
            headers=auth_headers,
            json={"rental_id": rental.id}
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["status"] == "returned"

    def test_return_boat_not_found(self, client, auth_headers):
        """测试还船记录不存在"""
        response = client.post(
            "/api/boats/return",
            headers=auth_headers,
            json={"rental_id": 99999}
        )
        assert response.status_code == status.HTTP_404_NOT_FOUND


class TestBoatsRentals:
    """测试租赁记录端点"""

    def test_get_my_rentals(self, client, auth_headers):
        """测试获取我的租赁记录"""
        response = client.get("/api/boats/rentals", headers=auth_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert isinstance(data, list)

    def test_get_all_rentals_admin(self, client, admin_headers):
        """测试管理员获取所有租赁记录"""
        response = client.get("/api/boats/all/rentals", headers=admin_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert isinstance(data, list)

    def test_get_all_rentals_no_permission(self, client, auth_headers):
        """测试普通用户无权限"""
        response = client.get("/api/boats/all/rentals", headers=auth_headers)
        assert response.status_code == status.HTTP_403_FORBIDDEN
