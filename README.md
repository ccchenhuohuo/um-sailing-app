# ⛵ UM Sailing App ⛵

### 澳门大学帆船协会移动应用

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.41-blue?style=for-the-badge&logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/FastAPI-0.109-green?style=for-the-badge&logo=fastapi" alt="FastAPI">
  <img src="https://img.shields.io/badge/MySQL-8.0-blue?style=for-the-badge&logo=mysql" alt="MySQL">
  <img src="https://img.shields.io/badge/Python-3.11+-yellow?style=for-the-badge&logo=python" alt="Python">
</p>

---

## 🌟 项目概述

> **UM Sailing App** 是澳门大学帆船协会 (University of Macau Sailing Association) 的移动应用系统，采用前后端分离架构开发。该应用旨在为帆船协会会员提供便捷的**活动管理**、**船只租借**、**在线论坛**等服务。

### 🎯 项目目标

| 目标 | 描述 |
|------|------|
| 🚀 | 为协会会员提供一站式的活动报名和船只租借平台 |
| 📱 | 实现无纸化会员管理 |
| 💬 | 提供会员间交流的社区论坛 |
| ⚙️ | 支持管理员高效管理协会资源 |

---

## 🛠️ 功能模块

### 2.1 🔐 用户认证

<p align="center">
<img src="https://img.shields.io/badge/-注册-4CAF50?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-登录-2196F3?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-JWT认证-FF9800?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-权限管理-9C27B0?style=flat">
</p>

- 用户注册（用户名、邮箱、密码）
- 用户登录（JWT Token 认证）
- Token 刷新机制
- 权限管理（普通用户/管理员）

---

### 2.2 🎪 活动管理

<p align="center">
<img src="https://img.shields.io/badge/-发布活动-4CAF50?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-活动报名-2196F3?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-活动签到-FF9800?style=flat">
</p>

- 📋 发布活动（标题、描述、地点、时间、人数限制）
- 📅 活动列表展示（即将开始/已结束）
- ✋ 活动报名参加
- ✅ 活动签到功能
- 📝 查看我的报名记录

---

### 2.3 🚤 船只管理

<p align="center">
<img src="https://img.shields.io/badge/-船只列表-4CAF50?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-船只租借-2196F3?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-船只归还-FF9800?style=flat">
</p>

- 🚢 船只列表展示（3列网格布局）
- 🟢 船只状态管理（可用/已租/维护中）
- 💰 船只租借功能
- 🔄 船只归还功能
- 📊 租借记录查询

---

### 2.4 💳 财务管理

<p align="center">
<img src="https://img.shields.io/badge/-余额查询-4CAF50?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-账户充值-2196F3?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-交易记录-FF9800?style=flat">
</p>

- 💰 账户余额查询
- 📥 账户充值（管理员操作）
- 📊 交易记录查询
- 📈 财务报告（管理员）

---

### 2.5 📝 论坛系统

<p align="center">
<img src="https://img.shields.io/badge/-发布帖子-4CAF50?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-浏览帖子-2196F3?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-发表评论-FF9800?style=flat">
</p>

- 📝 帖子发布（支持标签分类）
- 📖 帖子列表浏览
- 🔍 帖子详情查看
- 💬 发表评论功能
- 👥 评论列表展示

---

### 2.6 📢 通知公告

<p align="center">
<img src="https://img.shields.io/badge/-公告列表-4CAF50?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-发布公告-2196F3?style=flat">
</p>

- 📢 公告列表展示
- 🔎 公告详情查看
- ✏️ 发布公告（管理员）

---

### 2.7 ⚙️ 管理员后台

<p align="center">
<img src="https://img.shields.io/badge/-用户管理-4CAF50?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-财务管理-2196F3?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-船只管理-FF9800?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-数据统计-9C27B0?style=flat">
</p>

- 👥 用户管理
- 💳 财务管理
- 🚤 船只管理
- 📊 数据统计

---

## 💻 技术栈

### 3.1 🐍 后端技术栈

| 技术 | 版本 | 说明 |
|------|------|------|
| 🐍 Python | 3.11+ | 运行环境 |
| ⚡ FastAPI | 0.109+ | Web 框架 |
| 🗄️ SQLAlchemy | - | ORM 框架 |
| 🐬 MySQL | 8.0+ | 数据库 |
| ✅ Pydantic | - | 数据验证 |
| 🔑 python-jose | - | JWT 认证 |
| 🔒 Passlib | - | 密码哈希 |
| 🚀 Uvicorn | - | ASGI 服务器 |

### 3.2 📱 前端技术栈

| 技术 | 版本 | 说明 |
|------|------|------|
| 🌈 Flutter | 3.41+ | UI 框架 |
| 🌊 Riverpod | - | 状态管理 |
| 🛤️ GoRouter | - | 路由管理 |
| 🌐 Dio | - | HTTP 客户端 |
| 💾 SharedPreferences | - | 本地存储 |

### 3.3 🏗️ 系统架构

```
┌─────────────────────────────────────────────────────────┐
│                    🌐 Flutter Web                        │
│                      (前端)                              │
└───────────────────────┬─────────────────────────────────┘
                        │ HTTP / JSON
                        ▼
┌─────────────────────────────────────────────────────────┐
│                   ⚡ FastAPI API                         │
│                      (后端)                              │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│                      🐬 MySQL                           │
│                     (数据库)                             │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 项目结构

```
📦 um-sailing-app/
│
├── 📄 README.md                    # 项目主文档
├── 🧪 test_api.sh                  # API 测试脚本
├── 🧪🧪 test_api_full.sh          # 完整 API 测试脚本
│
├── 📂 backend/                     # 🐍 Python FastAPI 后端
│   ├── 📂 app/
│   │   ├── 🎯 main.py              # 应用入口
│   │   ├── ⚙️ config.py            # 配置管理
│   │   ├── 🗄️ database.py         # 数据库连接
│   │   ├── 📊 models/              # SQLAlchemy 模型
│   │   │   ├── 👤 user.py          # 用户模型
│   │   │   ├── 🎪 activity.py      # 活动模型
│   │   │   ├── 🚤 boat.py          # 船只模型
│   │   │   ├── 💰 finance.py       # 财务模型
│   │   │   ├── 📝 forum.py         # 论坛模型
│   │   │   ├── 📢 notice.py        # 通知模型
│   │   │   └── 📋 signup.py        # 报名模型
│   │   ├── 📋 schemas/             # Pydantic 数据模型
│   │   ├── 🛤️ routers/             # API 路由
│   │   │   ├── 🔐 auth.py          # 认证路由
│   │   │   ├── 👤 users.py         # 用户路由
│   │   │   ├── 🎪 activities.py    # 活动路由
│   │   │   ├── 🚤 boats.py         # 船只路由
│   │   │   ├── 💰 finances.py      # 财务路由
│   │   │   ├── 📢 notices.py       # 通知路由
│   │   │   ├── 📝 forum.py         # 论坛路由
│   │   │   ├── 📊 stats.py         # 统计路由
│   │   │   └── 🔧 deps.py          # 依赖注入
│   │   └── 🔧 utils/
│   │       └── 🔑 security.py      # JWT 工具
│   ├── 🗄️ init_database.sql        # 数据库建表脚本
│   ├── 🚀 init_db.py               # 数据库初始化
│   ├── 📦 requirements.txt        # Python 依赖
│   ├── 🧪 pytest.ini              # Pytest 配置
│   └── 🔐 .env                    # 环境变量
│
├── 📂 frontend/                    # 🌈 Flutter 前端
│   ├── 📂 lib/
│   │   ├── 🎯 main.dart            # 应用入口
│   │   ├── 🌐 app.dart             # 根组件
│   │   ├── ⚙️ config/
│   │   │   ├── 📝 constants.dart   # 常量配置
│   │   │   └── 🎨 theme.dart      # 主题配置
│   │   ├── 📊 models/              # 数据模型
│   │   │   ├── 👤 user.dart
│   │   │   ├── 🎪 activity.dart
│   │   │   ├── 📋 activity_signup.dart
│   │   │   ├── 🚤 boat.dart
│   │   │   ├── 📋 boat_rental.dart
│   │   │   ├── 📢 notice.dart
│   │   │   ├── 📝 post.dart
│   │   │   ├── 📊 stats.dart
│   │   │   └── 💰 transaction_record.dart
│   │   ├── 🌊 providers/           # Riverpod 状态管理
│   │   │   └── 🔐 auth_provider.dart
│   │   ├── 🌐 services/
│   │   │   └── 🔗 api_service.dart # API 服务
│   │   ├── 📱 screens/            # 页面组件
│   │   │   ├── 🚀 splash/          # 启动页
│   │   │   ├── 🔐 auth/            # 登录/注册页
│   │   │   ├── 🏠 home/            # 主页
│   │   │   ├── 🎪 activities/      # 活动页
│   │   │   │   ├── activities_screen.dart
│   │   │   │   └── activity_detail_screen.dart
│   │   │   ├── 🚤 boats/           # 船只页
│   │   │   ├── 👤 profile/         # 个人中心
│   │   │   │   ├── profile_screen.dart
│   │   │   │   ├── profile_edit_screen.dart
│   │   │   │   ├── my_activities_screen.dart
│   │   │   │   ├── my_rentals_screen.dart
│   │   │   │   └── transaction_history_screen.dart
│   │   │   └── ⚙️ admin/          # 管理后台
│   │   │       ├── admin_screen.dart
│   │   │       ├── users_tab.dart
│   │   │       ├── boats_tab.dart
│   │   │       ├── activities_tab.dart
│   │   │       ├── finance_tab.dart
│   │   │       ├── notices_tab.dart
│   │   │       └── stats_tab.dart
│   │   └── 🎨 widgets/
│   │       └── 🌊 ocean/           # 海洋主题组件
│   │           ├── 🌊 ocean_background.dart
│   │           └── 🌊 wave_painter.dart
│   └── 📦 pubspec.yaml
│
├── 📂 docs/                        # 📚 文档
│   └── 📊 test-report.md          # 测试报告
│
└── 📂 screenshots/                 # 📸 测试截图
```

---

## 📡 API 文档

> ⚡ 后端运行后，可访问 **http://localhost:8000/docs** 查看完整的 Swagger API 文档。

### 5.1 🔐 认证模块 (Auth) - 4 个 API

| 方法 | 端点 | 描述 | 认证要求 |
|------|------|------|----------|
| `POST` | `/api/auth/register` | 👤 用户注册 | 🟢 公开 |
| `POST` | `/api/auth/login` | 🔑 用户登录 | 🟢 公开 |
| `GET` | `/api/auth/me` | 👤 获取当前用户信息 | 🔒 需要认证 |
| `POST` | `/api/auth/refresh` | 🔄 刷新 Token | 🔒 需要认证 |

### 5.2 👤 用户模块 (Users) - 6 个 API

| 方法 | 端点 | 描述 | 认证要求 |
|------|------|------|----------|
| `GET` | `/api/users` | 📋 获取用户列表 | 🔴 管理员 |
| `GET` | `/api/users/me` | 👤 获取当前用户信息 | 🔒 需要认证 |
| `GET` | `/api/users/{user_id}` | 👤 获取指定用户 | 🔒 需要认证 |
| `PUT` | `/api/users/{user_id}` | ✏️ 更新用户信息 | 🔒 需要认证 |
| `DELETE` | `/api/users/{user_id}` | 🗑️ 删除用户 | 🔴 管理员 |
| `POST` | `/api/users/{user_id}/balance` | 💰 更新用户余额 | 🔴 管理员 |

### 5.3 🎪 活动模块 (Activities) - 9 个 API

| 方法 | 端点 | 描述 | 认证要求 |
|------|------|------|----------|
| `GET` | `/api/activities` | 📋 获取活动列表 | 🔒 需要认证 |
| `GET` | `/api/activities/{activity_id}` | 🔍 获取活动详情 | 🔒 需要认证 |
| `POST` | `/api/activities` | ➕ 创建活动 | 🔒 需要认证 |
| `PUT` | `/api/activities/{activity_id}` | ✏️ 更新活动 | 🔒 需要认证 |
| `DELETE` | `/api/activities/{activity_id}` | 🗑️ 删除活动 | 🔒 需要认证 |
| `POST` | `/api/activities/signup` | ✋ 报名活动 | 🔒 需要认证 |
| `POST` | `/api/activities/{activity_id}/checkin` | ✅ 活动签到 | 🔒 需要认证 |
| `GET` | `/api/activities/my/signups` | 📝 获取我的报名列表 | 🔒 需要认证 |
| `GET` | `/api/activities/{activity_id}/signups` | 📋 获取活动报名列表 | 🔒 需要认证 |

### 5.4 🚤 船只模块 (Boats) - 10 个 API

| 方法 | 端点 | 描述 | 认证要求 |
|------|------|------|----------|
| `GET` | `/api/boats` | 🚤 获取船只列表 | 🔒 需要认证 |
| `GET` | `/api/boats/rentals` | 📋 获取我的租借记录 | 🔒 需要认证 |
| `GET` | `/api/boats/all/rentals` | 📋 获取所有租借记录 | 🔴 管理员 |
| `GET` | `/api/boats/{boat_id}` | 🔍 获取船只详情 | 🔒 需要认证 |
| `POST` | `/api/boats` | ➕ 创建船只 | 🔴 管理员 |
| `PUT` | `/api/boats/{boat_id}` | ✏️ 更新船只 | 🔴 管理员 |
| `DELETE` | `/api/boats/{boat_id}` | 🗑️ 删除船只 | 🔴 管理员 |
| `POST` | `/api/boats/{boat_id}/rent` | 💰 租借船只 | 🔒 需要认证 |
| `POST` | `/api/boats/return` | 🔄 归还船只 | 🔒 需要认证 |

### 5.5 💰 财务模块 (Finances) - 6 个 API

| 方法 | 端点 | 描述 | 认证要求 |
|------|------|------|----------|
| `GET` | `/api/finances` | 📋 获取财务记录列表 | 🔒 需要认证 |
| `GET` | `/api/finances/balance` | 💰 获取当前用户余额 | 🔒 需要认证 |
| `POST` | `/api/finances` | ➕ 创建财务记录 | 🔴 管理员 |
| `POST` | `/api/finances/deposit` | 📥 账户充值 | 🔴 管理员 |
| `GET` | `/api/finances/report` | 📈 获取财务报告 | 🔴 管理员 |

### 5.6 📢 通知模块 (Notices) - 5 个 API

| 方法 | 端点 | 描述 | 认证要求 |
|------|------|------|----------|
| `GET` | `/api/notices` | 📋 获取通知列表 | 🔒 需要认证 |
| `GET` | `/api/notices/{notice_id}` | 🔍 获取通知详情 | 🔒 需要认证 |
| `POST` | `/api/notices` | ➕ 创建通知 | 🔴 管理员 |
| `PUT` | `/api/notices/{notice_id}` | ✏️ 更新通知 | 🔴 管理员 |
| `DELETE` | `/api/notices/{notice_id}` | 🗑️ 删除通知 | 🔴 管理员 |

### 5.7 📝 论坛模块 (Forum) - 12 个 API

| 方法 | 端点 | 描述 | 认证要求 |
|------|------|------|----------|
| `GET` | `/api/forum/tags` | 🏷️ 获取标签列表 | 🔒 需要认证 |
| `POST` | `/api/forum/tags` | ➕ 创建标签 | 🔴 管理员 |
| `GET` | `/api/forum/posts` | 📋 获取帖子列表 | 🔒 需要认证 |
| `GET` | `/api/forum/posts/{post_id}` | 🔍 获取帖子详情 | 🔒 需要认证 |
| `POST` | `/api/forum/posts` | ➕ 创建帖子 | 🔒 需要认证 |
| `PUT` | `/api/forum/posts/{post_id}` | ✏️ 更新帖子 | 🔒 需要认证 |
| `DELETE` | `/api/forum/posts/{post_id}` | 🗑️ 删除帖子 | 🔒 需要认证 |
| `GET` | `/api/forum/posts/{post_id}/comments` | 💬 获取帖子评论 | 🔒 需要认证 |
| `POST` | `/api/forum/posts/{post_id}/comments` | ➕ 添加评论 | 🔒 需要认证 |
| `DELETE` | `/api/forum/comments/{comment_id}` | 🗑️ 删除评论 | 🔒 需要认证 |

> 📊 **API 总数：53 个** 🎉

### 5.8 📊 统计模块 (Stats) - 1 个 API

| 方法 | 端点 | 描述 | 认证要求 |
|------|------|------|----------|
| `GET` | `/api/stats` | 📊 获取统计数据仪表盘 | 🔴 管理员 |

### 5.9 🌍 系统级端点

| 方法 | 端点 | 描述 |
|------|------|------|
| `GET` | `/` | 🏠 根路径，返回 API 版本信息 |
| `GET` | `/health` | ❤️ 健康检查端点 |

---

## 🗄️ 数据库设计

> 项目使用 **MySQL** 数据库，共 **10 张数据表** 📊

### 6.1 👤 users 表 - 用户表

| 字段 | 类型 | 描述 |
|------|------|------|
| `id` | Integer | 🗝️ 主键，自增 |
| `username` | VARCHAR(50) | 👤 用户名，唯一 |
| `password_hash` | VARCHAR(255) | 🔒 密码哈希 |
| `email` | VARCHAR(100) | 📧 邮箱，唯一 |
| `phone` | VARCHAR(20) | 📱 电话号码 |
| `role` | ENUM('USER', 'ADMIN') | 🎭 角色 |
| `balance` | DECIMAL(10,2) | 💰 账户余额 |
| `created_at` | DATETIME | ⏰ 创建时间 |
| `updated_at` | DATETIME | ⏰ 更新时间 |

### 6.2 🎪 activities 表 - 活动表

| 字段 | 类型 | 描述 |
|------|------|------|
| `id` | Integer | 🗝️ 主键，自增 |
| `title` | VARCHAR(100) | 📝 活动标题 |
| `description` | TEXT | 📄 活动描述 |
| `location` | 📍 VARCHAR(100) | 活动地点 |
| `start_time` | DATETIME | 🕐 开始时间 |
| `end_time` | DATETIME | 🕕 结束时间 |
| `max_participants` | Integer | 👥 最大参与人数 |
| `creator_id` | Integer | 👤 创建者ID (外键) |

### 6.3 📋 activity_signups 表 - 活动报名表

| 字段 | 类型 | 描述 |
|------|------|------|
| `id` | Integer | 🗝️ 主键，自增 |
| `activity_id` | Integer | 🎪 活动ID (外键) |
| `user_id` | Integer | 👤 用户ID (外键) |
| `signup_time` | DATETIME | ⏰ 报名时间 |
| `check_in` | Boolean | ✅ 是否签到 |

### 6.4 🚤 boats 表 - 船只表

| 字段 | 类型 | 描述 |
|------|------|------|
| `id` | Integer | 🗝️ 主键，自增 |
| `name` | VARCHAR(50) | 🚤 船只名称 |
| `type` | VARCHAR(50) | 🏷️ 船只类型 |
| `status` | ENUM | 🟢 状态 (可用/已租/维护) |
| `rental_price` | DECIMAL(10,2) | 💰 租借价格/小时 |
| `image_url` | VARCHAR(255) | 🖼️ 图片URL |
| `description` | TEXT | 📄 描述 |

### 6.5 📋 boats_rentals 表 - 船只租借表

| 字段 | 类型 | 描述 |
|------|------|------|
| `id` | Integer | 🗝️ 主键，自增 |
| `boat_id` | Integer | 🚤 船只ID (外键) |
| `user_id` | Integer | 👤 用户ID (外键) |
| `rental_time` | DATETIME | ⏰ 租借时间 |
| `return_time` | DATETIME | ⏰ 归还时间 |
| `status` | VARCHAR(20) | 📊 状态 (active/returned) |

### 6.6 💰 finances 表 - 财务表

| 字段 | 类型 | 描述 |
|------|------|------|
| `id` | Integer | 🗝️ 主键，自增 |
| `user_id` | Integer | 👤 用户ID (外键) |
| `type` | ENUM | 📊 类型 (INCOME/EXPENSE) |
| `amount` | DECIMAL(10,2) | 💵 金额 |
| `description` | TEXT | 📝 描述 |
| `created_at` | DATETIME | ⏰ 创建时间 |

### 6.7 📢 notices 表 - 通知表

| 字段 | 类型 | 描述 |
|------|------|------|
| `id` | Integer | 🗝️ 主键，自增 |
| `title` | VARCHAR(100) | 📢 通知标题 |
| `content` | TEXT | 📄 通知内容 |
| `author_id` | Integer | 👤 作者ID (外键) |

### 6.8 📝 posts 表 - 帖子表

| 字段 | 类型 | 描述 |
|------|------|------|
| `id` | Integer | 🗝️ 主键，自增 |
| `user_id` | Integer | 👤 作者ID (外键) |
| `title` | VARCHAR(100) | 📝 帖子标题 |
| `content` | TEXT | 📄 帖子内容 |
| `tag_id` | Integer | 🏷️ 标签ID (外键) |

### 6.9 💬 comments 表 - 评论表

| 字段 | 类型 | 描述 |
|------|------|------|
| `id` | Integer | 🗝️ 主键，自增 |
| `post_id` | Integer | 📝 帖子ID (外键) |
| `user_id` | Integer | 👤 用户ID (外键) |
| `content` | TEXT | 💬 评论内容 |
| `created_at` | DATETIME | ⏰ 创建时间 |

### 6.10 🏷️ tags 表 - 标签表

| 字段 | 类型 | 描述 |
|------|------|------|
| `id` | Integer | 🗝️ 主键，自增 |
| `name` | VARCHAR(50) | 🏷️ 标签名称，唯一 |

---

## 🚀 快速开始

### 7.1 📋 环境要求

<p align="center">
<img src="https://img.shields.io/badge/-Python 3.11+-yellow?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-Node.js 18+-green?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-Flutter 3.41+-blue?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-MySQL 8.0+-orange?style=flat">
</p>

| 要求 | 版本 |
|------|------|
| 🐍 Python | 3.11+ |
| 🟢 Node.js | 18+ (用于前端开发) |
| 🌈 Flutter SDK | 3.41+ |
| 🐬 MySQL | 8.0+ |

---

### 7.2 🐍 后端设置

```bash
# 🎬 1. 进入后端目录
cd backend

# 🏗️ 2. 创建虚拟环境
python -m venv venv

# ▶️  3. 激活虚拟环境
source venv/bin/activate  # Linux/Mac
# 或
venv\Scripts\activate     # Windows

# 📦 4. 安装依赖
pip install -r requirements.txt

# 🗄️ 5. 配置数据库
# 编辑 .env 文件，设置数据库连接信息
# 执行 init_database.sql 创建数据库表

# 🚀 6. 运行服务器
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

> ✅ **后端启动后：**
> - 🌐 API 地址：http://localhost:8000
> - 📚 Swagger 文档：http://localhost:8000/docs

---

### 7.3 🌈 前端设置

```bash
# 🎬 1. 进入前端目录
cd frontend

# 📦 2. 安装依赖
flutter pub get

# ▶️  3. 运行应用（开发模式）
flutter run -d chrome

# 🏗️ 或者构建 Web 版本
flutter build web
```

> ✅ **前端启动后：**
> - 🌐 Web 地址：http://127.0.0.1:5173

---

### 7.4 🧪 测试账号

| 🎭 角色 | 👤 用户名 | 🔑 密码 |
|---------|----------|---------|
| 🔴 管理员 | `admin` | `admin123` |
| 🟢 普通用户 | `user1` | `user123` |

---

## ✅ 测试结果

### 8.1 🧪 API 测试概览

项目包含完整的 API 测试脚本，可通过以下命令运行：

```bash
# ⚡ 快速测试
./test_api.sh

# 🔬 完整测试
./test_api_full.sh
```

### 8.2 📊 测试通过情况

| 模块 | 测试状态 | 说明 |
|------|----------|------|
| 🔐 认证模块 | ✅ 通过 | 注册、登录、Token 刷新正常 |
| 👤 用户模块 | ✅ 通过 | 用户信息获取、余额更新正常 |
| 🎪 活动模块 | ✅ 通过 | 活动创建、报名、签到正常 |
| 🚤 船只模块 | ✅ 通过 | 船只 CRUD、租借、归还正常 |
| 💰 财务模块 | ✅ 通过 | 充值、记录查询正常 |
| 📢 通知模块 | ✅ 通过 | 公告发布、查看正常 |
| 📝 论坛模块 | ✅ 通过 | 帖子、评论功能正常 |

### 8.3 🔧 已修复问题

| # | 问题 | 状态 |
|---|------|------|
| 1 | 🐛 船只状态枚举问题 | ✅ 已修复 |
| 2 | 🐛 前端菜单点击无反应 | ✅ 已修复 |
| 3 | 🐛 帖子评论发送功能 | ✅ 已修复 |
| 4 | 🎨 船只卡片布局 | ✅ 已优化 |

---

## 📈 开发进度

### 9.1 ✅ 已完成功能

#### 🐍 后端 (FastAPI)

<p align="center">
<img src="https://img.shields.io/badge/-用户认证系统-4CAF50?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-用户管理-2196F3?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-活动管理-FF9800?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-船只管理-9C27B0?style=flat">
</p>

- ✅ [x] 🔐 用户认证系统 (JWT)
- ✅ [x] 👤 用户管理
- ✅ [x] 🎪 活动管理 (CRUD + 报名 + 签到)
- ✅ [x] 🚤 船只管理 (CRUD + 租借 + 归还)
- ✅ [x] 💰 财务管理 (充值 + 记录)
- ✅ [x] 📢 通知公告系统
- ✅ [x] 📝 论坛系统 (帖子 + 评论 + 标签)
- ✅ [x] ⚙️ 管理员权限控制
- ✅ [x] 📊 数据统计API (Stats)

#### 🌈 前端 (Flutter)

<p align="center">
<img src="https://img.shields.io/badge/-启动页-4CAF50?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-登录注册-2196F3?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-主页-FF9800?style=flat">&nbsp;
<img src="https://img.shields.io/badge/-个人中心-9C27B0?style=flat">
</p>

- ✅ [x] 🚀 启动页 (Splash Screen)
- ✅ [x] 🔐 用户登录/注册
- ✅ [x] 🏠 主页 (底部导航 + 5个子页面)
- ✅ [x] 🎪 活动列表与详情
- ✅ [x] 🎪 活动报名与签到
- ✅ [x] 🚤 船只列表与详情
- ✅ [x] 🚤 船只租借与归还
- ✅ [x] 📝 论坛帖子与评论
- ✅ [x] 👤 个人中心
  - ✅ 余额查询与充值
  - ✅ 我的活动报名记录
  - ✅ 我的船只租借记录
  - ✅ 交易历史记录
  - ✅ 个人信息编辑
- ✅ [x] ⚙️ 管理员后台
  - ✅ 用户管理 (查看、编辑、删除、权限设置、余额管理)
  - ✅ 船只管理 (CRUD、状态切换、租借记录查看)
  - ✅ 活动管理 (CRUD、报名管理、一键签到)
  - ✅ 财务管理 (充值、交易记录查看)
  - ✅ 公告管理 (CRUD)
  - ✅ 数据统计仪表盘 (用户数、活动数、船只数、收入趋势、图表展示)
- ✅ [x] 🌊 海洋主题 UI 组件

### 9.2 ⏳ 待开发功能

| 功能模块 | ⭐ 优先级 | 📝 说明 |
|----------|----------|---------|
| ✅ 充值页面 | 🟢 已完成 | 个人中心的充值功能 UI |
| ✅ 租船记录 | 🟢 已完成 | 租船历史记录页面 |
| ✅ 我的活动 | 🟢 已完成 | 报名活动历史页面 |
| ✅ 交易记录 | 🟢 已完成 | 交易明细页面 |
| ✅ 账户设置 | 🟢 已完成 | 个人信息修改页面 |
| ℹ️ 帮助与反馈 | 🟢 低 | 反馈提交页面 |
| ℹ️ 关于我们 | 🟢 低 | 应用信息展示 |
| ✅ 统计数据 | 🟢 已完成 | 管理员统计图表（收入趋势、活动参与、船只使用率） |

### 9.3 📅 最近更新

| 日期 | 更新内容 |
|------|----------|
| 📅 2026-02-22 | 🚀 管理后台完善：新增独立Tab页面（用户、船只、活动、公告、财务、统计管理），重构为模块化架构 |
| 📅 2026-02-22 | 📊 数据统计功能：新增Stats API和前端统计图表（使用fl_chart） |
| 📅 2026-02-22 | 👤 个人中心完善：新增我的活动、我的租借、交易记录、资料编辑页面 |
| 📅 2026-02-19 | 🎉 修复船只卡片布局、优化评论功能、添加菜单点击反馈 |
| 📅 2026-02-12 | 🐛 修复船只状态枚举问题 |
| 📅 初始版本 | 🚀 项目发布 |

---

## ❓ 常见问题 (FAQ)

### Q1: 如何启动后端服务？

> **A:** 在 backend 目录运行 `uvicorn app.main:app --reload`

```bash
cd backend
uvicorn app.main:app --reload
```

---

### Q2: 前端无法连接后端 API？

> **A:** 检查 `frontend/lib/services/api_service.dart` 中的 `API_BASE_URL` 是否正确

---

### Q3: 如何添加新用户为管理员？

> **A:** 在数据库中手动将用户的 `role` 字段设置为 `'ADMIN'`

---

### Q4: 船只租借失败怎么办？

> **A:** 检查用户账户余额是否充足，以及船只状态是否为 `AVAILABLE`

---

### Q5: 如何运行 API 测试？

> **A:** 项目根目录执行 `./test_api.sh` 或 `./test_api_full.sh`

---

### Q6: 前端页面点击没有反应？

> **A:** 已修复部分菜单项的点击事件，确保 `onTap` 回调已正确实现

---

## 🎨 界面预览

### 主题色系

<p align="center">

| 颜色 | 值 | 用途 |
|------|------|------|
| 🟢 主色 | `#1E8C93` | 导航栏、按钮 |
| 🟡 强调色 | `#E8B84A` | 发送按钮、图标 |
| 🔵 背景色 | `#0A1628`, `#15203B` | 深色背景 |
| 🔴 错误色 | `#FF6B6B` | 错误提示、删除 |

</p>

### ✨ UI 特性

- 🌊 **海洋波浪动画背景** - 独特的海洋主题视觉体验
- ⬜ **统一的白色卡片容器** - 清晰的信息展示
- 📱 **响应式设计** - 支持 Web 和移动端
- 🎨 **Material Design 3** - 现代设计语言

---

## 🤝 贡献指南

欢迎提交 **Pull Request** 或 **Issue**！

```
1. 🍴 Fork 本仓库
2. 🌿 创建特性分支 (git checkout -b feature/xxx)
3. 💾 提交更改 (git commit -m 'Add xxx')
4. 📤 推送分支 (git push origin feature/xxx)
5. 🔀 创建 Pull Request
```

---

## 📜 许可证

<p align="center">

MIT License

</p>

---

## 📧 联系方式

<p align="center">

🧑‍💻 **项目维护者：** chenyu 
📮 **邮箱：** bc10441@um.edu.mo

</p>

---

<p align="center">
  <img src="https://img.shields.io/badge/-Made%20with%20%E2%9D%A4%EF%B8%8F-FF6B6B?style=for-the-badge">
  <img src="https://img.shields.io/badge/-UM%20Sailing%20App-1E8C93?style=for-the-badge">
</p>

<div align="center">

🚤 ⛵ **扬帆起航，探索无限可能** ⛵ 🚤

</div>
