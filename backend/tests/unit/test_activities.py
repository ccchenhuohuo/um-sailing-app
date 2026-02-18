"""
Activities 模块测试
测试 /api/activities 下的端点
"""
import pytest
from fastapi import status
from datetime import datetime, timedelta


class TestActivitiesList:
    """测试获取活动列表端点 /api/activities"""

    def test_get_activities(self, client, auth_headers, test_activity):
        """测试获取活动列表"""
        response = client.get("/api/activities", headers=auth_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert isinstance(data, list)
        assert len(data) > 0

    def test_get_activities_no_token(self, client):
        """测试无 token"""
        response = client.get("/api/activities")
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


class TestActivitiesCreate:
    """测试创建活动端点 POST /api/activities"""

    def test_create_activity(self, client, auth_headers):
        """测试创建活动"""
        start_time = (datetime.utcnow() + timedelta(days=7)).isoformat()
        end_time = (datetime.utcnow() + timedelta(days=7, hours=3)).isoformat()
        response = client.post(
            "/api/activities",
            headers=auth_headers,
            json={
                "title": "新活动",
                "description": "活动描述",
                "location": "澳门大学",
                "start_time": start_time,
                "end_time": end_time,
                "max_participants": 20
            }
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["title"] == "新活动"

    def test_create_activity_no_token(self, client):
        """测试无 token 创建活动"""
        response = client.post("/api/activities", json={})
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


class TestActivitiesDetail:
    """测试活动详情端点"""

    def test_get_activity(self, client, auth_headers, test_activity):
        """测试获取活动详情"""
        response = client.get(f"/api/activities/{test_activity.id}", headers=auth_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["title"] == test_activity.title

    def test_get_activity_not_found(self, client, auth_headers):
        """测试活动不存在"""
        response = client.get("/api/activities/99999", headers=auth_headers)
        assert response.status_code == status.HTTP_404_NOT_FOUND

    def test_update_activity_creator(self, client, auth_headers, test_activity):
        """测试活动创建者修改"""
        response = client.put(
            f"/api/activities/{test_activity.id}",
            headers=auth_headers,
            json={"title": "修改后的标题"}
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["title"] == "修改后的标题"

    def test_update_activity_no_permission(self, client, admin_headers, test_activity):
        """测试非创建者无权限修改"""
        # test_activity 是 test_user 创建的，admin_user 不是创建者
        response = client.put(
            f"/api/activities/{test_activity.id}",
            headers=admin_headers,
            json={"title": "修改后的标题"}
        )
        assert response.status_code == status.HTTP_403_FORBIDDEN

    def test_delete_activity_creator(self, client, auth_headers, test_activity):
        """测试活动创建者删除"""
        response = client.delete(f"/api/activities/{test_activity.id}", headers=auth_headers)
        assert response.status_code == status.HTTP_200_OK
        assert "删除成功" in response.json()["message"]

    def test_delete_activity_admin(self, client, admin_headers, test_activity):
        """测试管理员删除活动"""
        response = client.delete(f"/api/activities/{test_activity.id}", headers=admin_headers)
        assert response.status_code == status.HTTP_200_OK


class TestActivitySignup:
    """测试活动报名端点 POST /api/activities/signup"""

    def test_signup_activity(self, client, auth_headers, test_activity):
        """测试报名成功"""
        response = client.post(
            "/api/activities/signup",
            headers=auth_headers,
            json={"activity_id": test_activity.id}
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["activity_id"] == test_activity.id

    def test_signup_activity_not_found(self, client, auth_headers):
        """测试报名不存在的活动"""
        response = client.post(
            "/api/activities/signup",
            headers=auth_headers,
            json={"activity_id": 99999}
        )
        assert response.status_code == status.HTTP_404_NOT_FOUND

    def test_signup_duplicate(self, client, auth_headers, test_activity):
        """测试重复报名"""
        # 第一次报名
        client.post(
            "/api/activities/signup",
            headers=auth_headers,
            json={"activity_id": test_activity.id}
        )
        # 第二次报名
        response = client.post(
            "/api/activities/signup",
            headers=auth_headers,
            json={"activity_id": test_activity.id}
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "已报名此活动" in response.json()["detail"]


class TestActivityCheckin:
    """测试签到端点 POST /api/activities/{id}/checkin"""

    def test_checkin_success(self, client, auth_headers, test_activity, db_session):
        """测试签到成功"""
        # 先报名
        from app.models.signup import ActivitySignup
        signup = ActivitySignup(
            activity_id=test_activity.id,
            user_id=test_activity.creator_id
        )
        db_session.add(signup)
        db_session.commit()

        response = client.post(
            f"/api/activities/{test_activity.id}/checkin",
            headers=auth_headers
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["check_in"] is True

    def test_checkin_not_signed_up(self, client, auth_headers, test_activity):
        """测试未报名签到"""
        response = client.post(
            f"/api/activities/{test_activity.id}/checkin",
            headers=auth_headers
        )
        assert response.status_code == status.HTTP_404_NOT_FOUND


class TestActivitySignups:
    """测试报名列表端点 GET /api/activities/{id}/signups"""

    def test_get_signups_creator(self, client, auth_headers, test_activity, db_session):
        """测试活动创建者获取报名列表"""
        from app.models.signup import ActivitySignup
        signup = ActivitySignup(
            activity_id=test_activity.id,
            user_id=test_activity.creator_id
        )
        db_session.add(signup)
        db_session.commit()

        response = client.get(
            f"/api/activities/{test_activity.id}/signups",
            headers=auth_headers
        )
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert len(data) > 0

    def test_get_signups_no_permission(self, client, admin_headers, test_activity):
        """测试非创建者无权限"""
        response = client.get(
            f"/api/activities/{test_activity.id}/signups",
            headers=admin_headers
        )
        assert response.status_code == status.HTTP_403_FORBIDDEN


class TestMySignups:
    """测试我的报名端点 GET /api/activities/my/signups"""

    def test_get_my_signups(self, client, auth_headers, test_activity, db_session):
        """测试获取我的报名"""
        from app.models.signup import ActivitySignup
        signup = ActivitySignup(
            activity_id=test_activity.id,
            user_id=test_activity.creator_id
        )
        db_session.add(signup)
        db_session.commit()

        response = client.get("/api/activities/my/signups", headers=auth_headers)
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert isinstance(data, list)
