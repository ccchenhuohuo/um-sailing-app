"""
Finances 模块测试
测试 /api/finances 下的端点
"""
import pytest
from fastapi import status
from decimal import Decimal


class TestFinancesList:
    """测试获取财务记录端点 GET /api/finances"""

    def test_get_finances_user(self, client, auth_headers):
        """测试普通用户获取财务记录"""
        response = client.get("/api/finances", headers=auth_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert isinstance(data, list)

    def test_get_finances_by_type(self, client, auth_headers, admin_headers, db_session):
        """测试按类型筛选"""
        # 先创建财务记录
        from app.models.finance import Finance, FinanceType
        finance = Finance(
            user_id=1,  # 假设有用户ID
            type=FinanceType.INCOME,
            amount=100.0,
            description="测试"
        )
        db_session.add(finance)
        db_session.commit()

        response = client.get("/api/finances?type=income", headers=admin_headers)
        assert response.status_code == status.HTTP_200_OK

    def test_get_finances_no_token(self, client):
        """测试无 token"""
        response = client.get("/api/finances")
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


class TestFinancesBalance:
    """测试获取余额端点 GET /api/finances/balance"""

    def test_get_balance(self, client, auth_headers, test_user):
        """测试获取余额"""
        response = client.get("/api/finances/balance", headers=auth_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "total_balance" in data
        assert data["user_id"] == test_user.id


class TestFinancesCreate:
    """测试创建财务记录端点 POST /api/finances"""

    def test_create_finance_admin(self, client, admin_headers, test_user):
        """测试管理员创建财务记录"""
        response = client.post(
            "/api/finances",
            headers=admin_headers,
            json={
                "user_id": test_user.id,
                "type": "income",
                "amount": 100.0,
                "description": "测试收入"
            }
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert float(data["amount"]) == 100.0

    def test_create_finance_no_permission(self, client, auth_headers):
        """测试普通用户无权限"""
        response = client.post(
            "/api/finances",
            headers=auth_headers,
            json={"type": "income", "amount": 100.0}
        )
        assert response.status_code == status.HTTP_403_FORBIDDEN


class TestFinancesDeposit:
    """测试充值端点 POST /api/finances/deposit"""

    def test_deposit_admin(self, client, admin_headers, test_user):
        """测试管理员充值"""
        original_balance = float(test_user.balance)
        response = client.post(
            f"/api/finances/deposit?amount=100.0&user_id={test_user.id}",
            headers=admin_headers
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["new_balance"] == original_balance + 100.0

    def test_deposit_user_not_found(self, client, admin_headers):
        """测试充值不存在的用户"""
        response = client.post(
            "/api/finances/deposit?amount=100.0&user_id=99999",
            headers=admin_headers
        )
        assert response.status_code == status.HTTP_404_NOT_FOUND


class TestFinancesReport:
    """测试财务报表端点 GET /api/finances/report"""

    def test_get_report_admin(self, client, admin_headers, db_session):
        """测试管理员获取财务报表"""
        from app.models.finance import Finance, FinanceType
        # 创建测试数据
        finance1 = Finance(user_id=1, type=FinanceType.INCOME, amount=500.0, description="收入1")
        finance2 = Finance(user_id=1, type=FinanceType.EXPENSE, amount=200.0, description="支出1")
        db_session.add(finance1)
        db_session.add(finance2)
        db_session.commit()

        response = client.get("/api/finances/report", headers=admin_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "total_income" in data
        assert "total_expense" in data
        assert "net_balance" in data

    def test_get_report_no_permission(self, client, auth_headers):
        """测试普通用户无权限"""
        response = client.get("/api/finances/report", headers=auth_headers)
        assert response.status_code == status.HTTP_403_FORBIDDEN
