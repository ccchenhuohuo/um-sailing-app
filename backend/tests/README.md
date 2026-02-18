# 后端测试

本目录包含 UM Sailing App 后端 API 的单元测试和集成测试。

## 测试结构

```
tests/
├── conftest.py           # pytest fixtures 和配置
├── unit/
│   ├── test_auth.py      # 认证模块测试 (4 端点)
│   ├── test_users.py     # 用户模块测试 (6 端点)
│   ├── test_activities.py # 活动模块测试 (9 端点)
│   ├── test_boats.py     # 船只模块测试 (9 端点)
│   ├── test_finances.py  # 财务模块测试 (5 端点)
│   ├── test_notices.py   # 公告模块测试 (5 端点)
│   └── test_forum.py     # 论坛模块测试 (9 端点)
```

## 安装测试依赖

```bash
cd backend
pip install -r requirements.txt
```

## 运行测试

### 运行所有测试

```bash
pytest
```

### 运行特定模块测试

```bash
pytest tests/unit/test_auth.py
```

### 运行特定测试类

```bash
pytest tests/unit/test_auth.py::TestAuthRegister
```

### 运行特定测试用例

```bash
pytest tests/unit/test_auth.py::TestAuthRegister::test_register_success
```

### 显示详细输出

```bash
pytest -v
```

### 显示覆盖率

```bash
pytest --cov=app --cov-report=html
```

## 测试覆盖的 API 端点

### Auth 模块 (4 端点)
- `POST /api/auth/register` - 用户注册
- `POST /api/auth/login` - 用户登录
- `GET /api/auth/me` - 获取当前用户信息
- `POST /api/auth/refresh` - 刷新 token

### Users 模块 (6 端点)
- `GET /api/users` - 获取用户列表
- `GET /api/users/me` - 获取本人信息
- `GET /api/users/{id}` - 获取指定用户
- `PUT /api/users/{id}` - 更新用户信息
- `DELETE /api/users/{id}` - 删除用户
- `POST /api/users/{id}/balance` - 修改用户余额

### Activities 模块 (9 端点)
- `GET /api/activities` - 获取活动列表
- `GET /api/activities/{id}` - 获取活动详情
- `POST /api/activities` - 创建活动
- `PUT /api/activities/{id}` - 更新活动
- `DELETE /api/activities/{id}` - 删除活动
- `POST /api/activities/signup` - 报名活动
- `POST /api/activities/{id}/checkin` - 活动签到
- `GET /api/activities/{id}/signups` - 获取报名列表
- `GET /api/activities/my/signups` - 获取我的报名

### Boats 模块 (9 端点)
- `GET /api/boats` - 获取船只列表
- `GET /api/boats/{id}` - 获取船只详情
- `POST /api/boats` - 创建船只
- `PUT /api/boats/{id}` - 更新船只
- `DELETE /api/boats/{id}` - 删除船只
- `POST /api/boats/{id}/rent` - 租船
- `POST /api/boats/return` - 还船
- `GET /api/boats/rentals` - 获取我的租赁记录
- `GET /api/boats/all/rentals` - 获取所有租赁记录

### Finances 模块 (5 端点)
- `GET /api/finances` - 获取财务记录
- `GET /api/finances/balance` - 获取余额
- `POST /api/finances` - 创建财务记录
- `POST /api/finances/deposit` - 充值
- `GET /api/finances/report` - 获取财务报表

### Notices 模块 (5 端点)
- `GET /api/notices` - 获取公告列表
- `GET /api/notices/{id}` - 获取公告详情
- `POST /api/notices` - 创建公告
- `PUT /api/notices/{id}` - 更新公告
- `DELETE /api/notices/{id}` - 删除公告

### Forum 模块 (9 端点)
- `GET /api/forum/tags` - 获取标签列表
- `POST /api/forum/tags` - 创建标签
- `GET /api/forum/posts` - 获取帖子列表
- `GET /api/forum/posts/{id}` - 获取帖子详情
- `POST /api/forum/posts` - 创建帖子
- `PUT /api/forum/posts/{id}` - 更新帖子
- `DELETE /api/forum/posts/{id}` - 删除帖子
- `GET /api/forum/posts/{id}/comments` - 获取评论列表
- `POST /api/forum/posts/{id}/comments` - 创建评论
- `DELETE /api/forum/comments/{id}` - 删除评论

## 测试环境

测试使用 SQLite 内存数据库进行，不依赖外部 MySQL 数据库。

## Fixtures

主要 fixtures 位于 `conftest.py`:

- `client` - FastAPI TestClient
- `db_session` - 数据库会话
- `test_user` - 普通测试用户
- `admin_user` - 管理员用户
- `auth_headers` - 普通用户认证头
- `admin_headers` - 管理员认证头
- `test_activity` - 测试活动
- `test_boat` - 测试船只
- `test_notice` - 测试公告
- `test_tag` - 测试标签
- `test_post` - 测试帖子
- `test_comment` - 测试评论
