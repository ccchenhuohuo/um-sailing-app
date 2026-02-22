from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func, extract
from datetime import datetime
from calendar import monthrange
from typing import List, Dict

from app.database import get_db
from app.models.user import User
from app.models.boat import Boat, BoatRental
from app.models.activity import Activity
from app.models.signup import ActivitySignup
from app.models.finance import Finance, FinanceType
from app.routers.deps import get_current_admin

router = APIRouter(prefix="/stats", tags=["stats"])


def get_month_range(month_offset):
    """计算指定月份的起始和结束日期"""
    now = datetime.utcnow()
    # 计算目标月份
    target_month = now.month - month_offset
    target_year = now.year + (target_month - 1) // 12
    target_month = ((target_month - 1) % 12) + 1
    days_in_month = monthrange(target_year, target_month)[1]
    start = datetime(target_year, target_month, 1)
    end = datetime(target_year, target_month, days_in_month, 23, 59, 59)
    return start, end


def get_recent_months(n: int) -> List[datetime]:
    """获取最近n个月的起始日期列表（从最近到最远）"""
    now = datetime.utcnow()
    months = []
    for i in range(n - 1, -1, -1):
        target_month = now.month - i
        target_year = now.year + (target_month - 1) // 12
        target_month = ((target_month - 1) % 12) + 1
        months.append(datetime(target_year, target_month, 1))
    return months


@router.get("")
def get_stats(db: Session = Depends(get_db), current_user: User = Depends(get_current_admin)):
    """获取所有统计数据"""
    now = datetime.utcnow()
    month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)

    # 基础统计
    total_users = db.query(User).count()
    total_boats = db.query(Boat).count()
    total_activities = db.query(Activity).count()

    # 收入统计
    total_revenue = db.query(func.sum(Finance.amount)).filter(
        Finance.type == FinanceType.INCOME
    ).scalar() or 0

    monthly_revenue = db.query(func.sum(Finance.amount)).filter(
        Finance.type == FinanceType.INCOME,
        Finance.created_at >= month_start
    ).scalar() or 0

    # 活跃用户 (本月有租借或报名)
    active_users = db.query(BoatRental.user_id).filter(
        BoatRental.rental_time >= month_start
    ).distinct().count()

    # 船只使用统计 (使用 LEFT JOIN 一次性获取所有数据)
    boat_usage_query = db.query(
        Boat.id,
        Boat.name,
        func.count(BoatRental.id).label('rental_count')
    ).outerjoin(BoatRental, Boat.id == BoatRental.boat_id).group_by(Boat.id).all()

    boat_usage = [{
        "boat_id": boat.id,
        "boat_name": boat.name,
        "rental_count": boat.rental_count or 0,
    } for boat in boat_usage_query]

    # 收入历史 (近6个月) - 使用单次GROUP BY查询替代6次独立查询
    now = datetime.utcnow()
    six_months_ago = get_recent_months(6)[0]
    revenue_by_month = db.query(
        extract('year', Finance.created_at).label('year'),
        extract('month', Finance.created_at).label('month'),
        func.sum(Finance.amount).label('revenue')
    ).filter(
        Finance.type == FinanceType.INCOME,
        Finance.created_at >= six_months_ago
    ).group_by(
        extract('year', Finance.created_at),
        extract('month', Finance.created_at)
    ).all()

    # 构建月份到收入的映射
    revenue_map: Dict[str, float] = {}
    for row in revenue_by_month:
        month_key = f"{int(row.year)}-{int(row.month):02d}"
        revenue_map[month_key] = float(row.revenue or 0)

    revenue_history = []
    for month_start in get_recent_months(6):
        month_key = month_start.strftime("%Y-%m")
        revenue_history.append({
            "month": month_key,
            "revenue": revenue_map.get(month_key, 0),
        })

    # 活动参与统计 (近6个月) - 使用单次GROUP BY查询替代6次独立查询
    signup_by_month = db.query(
        extract('year', ActivitySignup.created_at).label('year'),
        extract('month', ActivitySignup.created_at).label('month'),
        func.count(ActivitySignup.id).label('count')
    ).filter(
        ActivitySignup.created_at >= six_months_ago
    ).group_by(
        extract('year', ActivitySignup.created_at),
        extract('month', ActivitySignup.created_at)
    ).all()

    # 构建月份到报名数的映射
    signup_map: Dict[str, int] = {}
    for row in signup_by_month:
        month_key = f"{int(row.year)}-{int(row.month):02d}"
        signup_map[month_key] = int(row.count or 0)

    activity_participation = []
    for month_start in get_recent_months(6):
        month_key = month_start.strftime("%Y-%m")
        activity_participation.append({
            "month": month_key,
            "count": signup_map.get(month_key, 0),
        })

    return {
        "total_users": total_users,
        "total_activities": total_activities,
        "total_boats": total_boats,
        "total_revenue": float(total_revenue),
        "monthly_revenue": float(monthly_revenue),
        "active_users": active_users,
        "boat_usage": boat_usage,
        "revenue_history": revenue_history,
        "activity_participation": activity_participation,
    }
