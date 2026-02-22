# 管理后台完善设计方案

## 背景

当前管理后台 (`/admin`) 仅有基础框架，需要实现完整的增删改查 (CRUD) 功能。

## 技术架构

### 后端
- 新建 `backend/app/routers/stats.py` 路由
- 统计 API: `GET /stats` 返回聚合统计数据

### 前端
- 扩展 `api_service.dart` 添加缺失的 API 方法
- 重构 `admin_screen.dart`，拆分为独立 Tab 文件
- 采用全新 UI 设计风格

## UI/UX 设计

### 布局
- **Dashboard 布局**：侧边栏导航 + 主内容区
- **卡片式设计**：每个功能模块使用独立卡片
- **数据可视化**：使用 fl_chart 实现图表展示
- **响应式设计**：适配不同屏幕尺寸

### 颜色方案
- 主色：`#1E8C93` (Ocean Teal)
- 强调色：`#E8B84A` (Golden Yellow)
- 背景：浅灰色 `#F5F7FA`
- 文字：深灰色 `#2C3E50`

## 各 Tab 功能详情

### 1. 用户管理
- 用户列表（表格展示）
- 搜索功能
- 查看详情
- 修改余额
- 设为管理员
- 删除用户

### 2. 船只管理
- 船只列表
- 添加船只
- 编辑船只
- 删除船只
- 状态切换（可用/维护）
- 查看租借记录

### 3. 财务管理
- 总余额显示
- 为用户充值
- 交易记录列表
- 财务报表图表

### 4. 活动管理
- 活动列表
- 发布活动
- 编辑活动
- 删除活动
- 报名管理
- 签到管理

### 5. 公告管理
- 公告列表
- 发布公告
- 编辑公告
- 删除公告

### 6. 统计
- Dashboard 卡片：
  - 总用户数
  - 总活动数
  - 总船只数
  - 总收入
  - 本月收入
  - 活跃用户
- 图表展示：
  - 收入趋势（折线图）
  - 活动参与（柱状图）
  - 船只使用率（饼图）

## API 设计

### 后端 Stats API

```python
# backend/app/routers/stats.py
GET /stats - 返回所有统计数据
```

响应格式：
```json
{
  "total_users": 100,
  "total_activities": 20,
  "total_boats": 15,
  "total_revenue": 50000.0,
  "monthly_revenue": 5000.0,
  "active_users": 30,
  "revenue_history": [...],
  "activity_participation": [...],
  "boat_usage": [...]
}
```

### 前端 API Service 扩展

| 方法 | 功能 |
|-----|------|
| `getUsers()` | 获取用户列表 |
| `getUser(int id)` | 获取用户详情 |
| `updateUser(int id, ...)` | 更新用户 |
| `deleteUser(int id)` | 删除用户 |
| `updateUserBalance(int userId, double amount)` | 更新用户余额 |
| `updateBoat(int id, ...)` | 更新船只 |
| `deleteBoat(int id)` | 删除船只 |
| `getAllRentals()` | 获取所有租借记录 |
| `getFinanceRecords()` | 获取财务记录 |
| `getActivitiesAdmin()` | 获取所有活动(管理员) |
| `updateActivity(int id, ...)` | 更新活动 |
| `deleteActivity(int id)` | 删除活动 |
| `getNoticesAdmin()` | 获取所有公告 |
| `createNotice(...)` | 创建公告 |
| `updateNotice(int id, ...)` | 更新公告 |
| `deleteNotice(int id)` | 删除公告 |
| `getStats()` | 获取统计数据 |

## 文件清单

| 操作 | 文件路径 |
|-----|----------|
| 修改 | `frontend/lib/services/api_service.dart` |
| 修改 | `frontend/lib/screens/admin/admin_screen.dart` |
| 新增 | `frontend/lib/screens/admin/users_tab.dart` |
| 新增 | `frontend/lib/screens/admin/finance_tab.dart` |
| 新增 | `frontend/lib/screens/admin/boats_tab.dart` |
| 新增 | `frontend/lib/screens/admin/stats_tab.dart` |
| 新增 | `frontend/lib/screens/admin/activities_tab.dart` |
| 新增 | `frontend/lib/screens/admin/notices_tab.dart` |
| 新增 | `backend/app/routers/stats.py` |

## 开发顺序

1. 阶段一：扩展 API 服务层
2. 阶段二：重构 Admin 页面架构
3. 阶段三：用户管理功能
4. 阶段四：船只管理功能
5. 阶段五：财务管理功能
6. 阶段六：活动管理功能
7. 阶段七：公告管理功能
8. 阶段八：统计功能

## 依赖包

```yaml
# frontend/pubspec.yaml
dependencies:
  fl_chart: ^0.68.0
```

## 注意事项

1. 所有管理员 API 需验证 `isAdmin` 权限
2. 表单提交前需验证输入合法性
3. API 调用失败需显示友好提示
4. 每次 CRUD 操作后需刷新列表
5. 删除操作必须二次确认
