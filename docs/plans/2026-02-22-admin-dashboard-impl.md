# 管理后台完善实现计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 实现完整的管理后台功能，包括用户管理、船只管理、财务管理、活动管理、公告管理和数据统计

**Architecture:**
- 后端：新建 stats.py 路由提供统计数据 API
- 前端：扩展 api_service.dart，重构 admin_screen.dart 为独立 Tab 文件
- 采用全新 Dashboard 布局设计

**Tech Stack:** Flutter (Dart), FastAPI (Python), fl_chart

---

## 阶段一：扩展 API 服务层

### Task 1: 扩展 api_service.dart - 用户管理 API

**Files:**
- Modify: `frontend/lib/services/api_service.dart`

**Step 1: 添加用户管理 API 方法**

在 api_service.dart 文件末尾添加以下方法：

```dart
// ===== Users Admin =====
Future<List<User>> getUsers({int skip = 0, int limit = 100}) async {
  final response = await _dio.get('/users', queryParameters: {
    'skip': skip,
    'limit': limit,
  });
  return (response.data as List).map((e) => User.fromJson(e)).toList();
}

Future<User> getUser(int id) async {
  final response = await _dio.get('/users/$id');
  return User.fromJson(response.data);
}

Future<User> updateUser(int id, {String? email, bool? isAdmin}) async {
  final response = await _dio.put('/users/$id', data: {
    if (email != null) 'email': email,
    if (isAdmin != null) 'is_admin': isAdmin,
  });
  return User.fromJson(response.data);
}

Future<void> deleteUser(int id) async {
  await _dio.delete('/users/$id');
}

Future<double> updateUserBalance(int userId, double amount) async {
  final response = await _dio.post('/users/$userId/balance', data: {'amount': amount});
  return double.parse(response.data['new_balance'].toString());
}
```

**Step 2: Commit**

```bash
git add frontend/lib/services/api_service.dart
git commit -m "feat: add user management API methods"
```

---

### Task 2: 扩展 api_service.dart - 船只管理 API

**Files:**
- Modify: `frontend/lib/services/api_service.dart`

**Step 1: 添加船只管理 API 方法**

```dart
// ===== Boats Admin =====
Future<Boat> updateBoat(int id, {String? name, double? rentalPrice, String? status}) async {
  final response = await _dio.put('/boats/$id', data: {
    if (name != null) 'name': name,
    if (rentalPrice != null) 'rental_price': rentalPrice,
    if (status != null) 'status': status,
  });
  return Boat.fromJson(response.data);
}

Future<void> deleteBoat(int id) async {
  await _dio.delete('/boats/$id');
}

Future<List<BoatRental>> getAllRentals() async {
  final response = await _dio.get('/boats/all/rentals');
  return (response.data as List).map((e) => BoatRental.fromJson(e)).toList();
}
```

**Step 2: Commit**

```bash
git add frontend/lib/services/api_service.dart
git commit -m "feat: add boat management API methods"
```

---

### Task 3: 扩展 api_service.dart - 财务管理 API

**Files:**
- Modify: `frontend/lib/services/api_service.dart`

**Step 1: 添加财务管理 API 方法**

```dart
// ===== Finances Admin =====
Future<List<FinanceRecord>> getFinanceRecords({int skip = 0, int limit = 100}) async {
  final response = await _dio.get('/finances/records', queryParameters: {
    'skip': skip,
    'limit': limit,
  });
  return (response.data as List).map((e) => FinanceRecord.fromJson(e)).toList();
}

Future<Map<String, dynamic>> getFinanceReport() async {
  final response = await _dio.get('/finances/report');
  return response.data;
}
```

**Step 2: Commit**

```bash
git add frontend/lib/services/api_service.dart
git commit -m "feat: add finance management API methods"
```

---

### Task 4: 扩展 api_service.dart - 活动公告管理 API

**Files:**
- Modify: `frontend/lib/services/api_service.dart`

**Step 1: 添加活动公告 API 方法**

```dart
// ===== Activities Admin =====
Future<Activity> updateActivity(int id, {
  String? title,
  String? description,
  String? location,
  DateTime? startTime,
  DateTime? endTime,
  int? maxParticipants,
}) async {
  final response = await _dio.put('/activities/$id', data: {
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (location != null) 'location': location,
    if (startTime != null) 'start_time': startTime.toIso8601String(),
    if (endTime != null) 'end_time': endTime.toIso8601String(),
    if (maxParticipants != null) 'max_participants': maxParticipants,
  });
  return Activity.fromJson(response.data);
}

Future<void> deleteActivity(int id) async {
  await _dio.delete('/activities/$id');
}

Future<List<ActivitySignup>> getActivitySignups(int activityId) async {
  final response = await _dio.get('/activities/$activityId/signups');
  return (response.data as List).map((e) => ActivitySignup.fromJson(e)).toList();
}

Future<void> checkinAllActivity(int activityId) async {
  await _dio.post('/activities/$activityId/checkin-all');
}

// ===== Notices Admin =====
Future<Notice> createNotice({required String title, required String content}) async {
  final response = await _dio.post('/notices', data: {
    'title': title,
    'content': content,
  });
  return Notice.fromJson(response.data);
}

Future<Notice> updateNotice(int id, {String? title, String? content}) async {
  final response = await _dio.put('/notices/$id', data: {
    if (title != null) 'title': title,
    if (content != null) 'content': content,
  });
  return Notice.fromJson(response.data);
}

Future<void> deleteNotice(int id) async {
  await _dio.delete('/notices/$id');
}
```

**Step 2: Commit**

```bash
git add frontend/lib/services/api_service.dart
git commit -m "feat: add activities and notices API methods"
```

---

### Task 5: 新建后端 stats.py 路由

**Files:**
- Create: `backend/app/routers/stats.py`
- Modify: `backend/app/main.py` (添加路由注册)

**Step 1: 创建 stats.py**

```python
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta
from typing import List, Dict, Any

from app.database import get_db
from app.models.user import User
from app.models.boat import Boat, BoatRental
from app.models.activity import Activity, ActivitySignup
from app.models.finance import FinanceRecord
from app.routers.deps import get_current_admin

router = APIRouter(prefix="/stats", tags=["stats"])


@router.get("")
def get_stats(db: Session = Depends(get_db), current_user = Depends(get_current_admin)):
    """获取所有统计数据"""
    now = datetime.utcnow()
    month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)

    # 基础统计
    total_users = db.query(User).count()
    total_boats = db.query(Boat).count()
    total_activities = db.query(Activity).count()

    # 收入统计
    total_revenue = db.query(func.sum(FinanceRecord.amount)).filter(
        FinanceRecord.type == "income"
    ).scalar() or 0

    monthly_revenue = db.query(func.sum(FinanceRecord.amount)).filter(
        FinanceRecord.type == "income",
        FinanceRecord.created_at >= month_start
    ).scalar() or 0

    # 活跃用户 (本月有租借或报名)
    active_users = db.query(BoatRental.user_id).filter(
        BoatRental.rental_time >= month_start
    ).distinct().count()

    # 船只使用统计
    boat_usage = []
    boats = db.query(Boat).all()
    for boat in boats:
        rental_count = db.query(BoatRental).filter(BoatRental.boat_id == boat.id).count()
        boat_usage.append({
            "boat_id": boat.id,
            "boat_name": boat.name,
            "rental_count": rental_count,
        })

    # 收入历史 (近6个月)
    revenue_history = []
    for i in range(5, -1, -1):
        month = (now - timedelta(days=30 * i)).replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        next_month = (month + timedelta(days=32)).replace(day=1, hour=0, minute=0, second=0, microsecond=0)

        month_revenue = db.query(func.sum(FinanceRecord.amount)).filter(
            FinanceRecord.type == "income",
            FinanceRecord.created_at >= month,
            FinanceRecord.created_at < next_month
        ).scalar() or 0

        revenue_history.append({
            "month": month.strftime("%Y-%m"),
            "revenue": float(month_revenue),
        })

    # 活动参与统计 (近6个月)
    activity_participation = []
    for i in range(5, -1, -1):
        month = (now - timedelta(days=30 * i)).replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        next_month = (month + timedelta(days=32)).replace(day=1, hour=0, minute=0, second=0, microsecond=0)

        signup_count = db.query(ActivitySignup).filter(
            ActivitySignup.created_at >= month,
            ActivitySignup.created_at < next_month
        ).count()

        activity_participation.append({
            "month": month.strftime("%Y-%m"),
            "count": signup_count,
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
```

**Step 2: 注册路由 (在 main.py)**

```python
from app.routers import stats

app.include_router(stats.router)
```

**Step 3: Commit**

```bash
git add backend/app/routers/stats.py backend/app/main.py
git commit -m "feat: add stats API endpoint"
```

---

### Task 6: 添加 Stats 模型和 API 方法

**Files:**
- Modify: `frontend/lib/models/index.dart` (如需要)
- Modify: `frontend/lib/services/api_service.dart`

**Step 1: 添加 Stats 模型**

```dart
// 在 models 中添加 Stats 类
class Stats {
  final int totalUsers;
  final int totalActivities;
  final int totalBoats;
  final double totalRevenue;
  final double monthlyRevenue;
  final int activeUsers;
  final List<BoatUsage> boatUsage;
  final List<RevenueHistory> revenueHistory;
  final List<ActivityParticipation> activityParticipation;

  Stats({
    required this.totalUsers,
    required this.totalActivities,
    required this.totalBoats,
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.activeUsers,
    required this.boatUsage,
    required this.revenueHistory,
    required this.activityParticipation,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      totalUsers: json['total_users'] ?? 0,
      totalActivities: json['total_activities'] ?? 0,
      totalBoats: json['total_boats'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      monthlyRevenue: (json['monthly_revenue'] ?? 0).toDouble(),
      activeUsers: json['active_users'] ?? 0,
      boatUsage: (json['boat_usage'] as List? ?? [])
          .map((e) => BoatUsage.fromJson(e))
          .toList(),
      revenueHistory: (json['revenue_history'] as List? ?? [])
          .map((e) => RevenueHistory.fromJson(e))
          .toList(),
      activityParticipation: (json['activity_participation'] as List? ?? [])
          .map((e) => ActivityParticipation.fromJson(e))
          .toList(),
    );
  }
}

class BoatUsage {
  final int boatId;
  final String boatName;
  final int rentalCount;

  BoatUsage({
    required this.boatId,
    required this.boatName,
    required this.rentalCount,
  });

  factory BoatUsage.fromJson(Map<String, dynamic> json) {
    return BoatUsage(
      boatId: json['boat_id'],
      boatName: json['boat_name'],
      rentalCount: json['rental_count'],
    );
  }
}

class RevenueHistory {
  final String month;
  final double revenue;

  RevenueHistory({required this.month, required this.revenue});

  factory RevenueHistory.fromJson(Map<String, dynamic> json) {
    return RevenueHistory(
      month: json['month'],
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}

class ActivityParticipation {
  final String month;
  final int count;

  ActivityParticipation({required this.month, required this.count});

  factory ActivityParticipation.fromJson(Map<String, dynamic> json) {
    return ActivityParticipation(
      month: json['month'],
      count: json['count'],
    );
  }
}
```

**Step 2: 添加 getStats API 方法**

```dart
Future<Stats> getStats() async {
  final response = await _dio.get('/stats');
  return Stats.fromJson(response.data);
}
```

**Step 3: Commit**

```bash
git add frontend/lib/models/index.dart frontend/lib/services/api_service.dart
git commit -m "feat: add Stats model and getStats API"
```

---

## 阶段二：重构 Admin 页面架构

### Task 7: 创建 users_tab.dart

**Files:**
- Create: `frontend/lib/screens/admin/users_tab.dart`

**Step 1: 创建用户管理 Tab**

实现完整的用户管理界面：
- 用户列表表格
- 搜索功能
- 查看详情弹窗
- 修改余额弹窗
- 设为管理员确认
- 删除用户确认

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../models/index.dart';
import '../../config/theme.dart';

class UsersTab extends ConsumerStatefulWidget {
  const UsersTab({super.key});

  @override
  ConsumerState<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends ConsumerState<UsersTab> {
  List<User> _users = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final users = await ApiService().getUsers();
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  List<User> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    return _users.where((u) => u.username.contains(_searchQuery)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: _loadUsers,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildUserList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索用户...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    final users = _filteredUsers;
    if (users.isEmpty) {
      return const Center(child: Text('暂无用户'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _UserCard(
          user: user,
          onRefresh: _loadUsers,
        );
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onRefresh;

  const _UserCard({required this.user, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1E8C93),
          child: Text(
            user.username[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(user.username),
        subtitle: Text(user.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user.isAdmin)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8B84A).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '管理员',
                  style: TextStyle(fontSize: 12, color: Color(0xFFE8B84A)),
                ),
              ),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('查看详情'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'balance',
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_wallet),
                      SizedBox(width: 8),
                      Text('修改余额'),
                    ],
                  ),
                ),
                if (!user.isAdmin)
                  const PopupMenuItem(
                    value: 'admin',
                    child: Row(
                      children: [
                        Icon(Icons.admin_panel_settings),
                        SizedBox(width: 8),
                        Text('设为管理员'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('删除', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) => _handleMenuAction(context, value),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String value) {
    switch (value) {
      case 'view':
        _showUserDetails(context);
        break;
      case 'balance':
        _showBalanceDialog(context);
        break;
      case 'admin':
        _setAsAdmin(context);
        break;
      case 'delete':
        _deleteUser(context);
        break;
    }
  }

  void _showUserDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('用户详情'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(label: '用户名', value: user.username),
            _DetailRow(label: '邮箱', value: user.email),
            _DetailRow(label: '余额', value: 'MOP ${user.balance}'),
            _DetailRow(label: '角色', value: user.isAdmin ? '管理员' : '普通用户'),
            _DetailRow(label: '注册时间', value: user.createdAt?.toString() ?? '-'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showBalanceDialog(BuildContext context) {
    final amountController = TextEditingController();
    bool isAdd = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('修改余额'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('增加'),
                    selected: isAdd,
                    onSelected: (selected) => setState(() => isAdd = true),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('减少'),
                    selected: !isAdd,
                    onSelected: (selected) => setState(() => isAdd = false),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '金额',
                  prefixText: 'MOP ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  await ApiService().updateUserBalance(
                    user.id,
                    isAdd ? amount : -amount,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    onRefresh();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('余额更新成功')),
                    );
                  }
                }
              },
              child: const Text('确认'),
            ),
          ],
        ),
      ),
    );
  }

  void _setAsAdmin(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认'),
        content: Text('确定要将 ${user.username} 设为管理员吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService().updateUser(user.id, isAdmin: true);
              if (context.mounted) {
                Navigator.pop(context);
                onRefresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('设置成功')),
                );
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除用户 ${user.username} 吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ApiService().deleteUser(user.id);
              if (context.mounted) {
                Navigator.pop(context);
                onRefresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('删除成功')),
                );
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
```

**Step 2: Commit**

```bash
git add frontend/lib/screens/admin/users_tab.dart
git commit -m "feat: add users tab with full CRUD functionality"
```

---

### Task 8: 创建 boats_tab.dart (完善现有)

**Files:**
- Modify: `frontend/lib/screens/admin/admin_screen.dart` (移除 BoatsManagementTab)
- Create: `frontend/lib/screens/admin/boats_tab.dart`

**Step 1: 创建船只管理 Tab**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../models/index.dart';

class BoatsTab extends ConsumerStatefulWidget {
  const BoatsTab({super.key});

  @override
  ConsumerState<BoatsTab> createState() => _BoatsTabState();
}

class _BoatsTabState extends ConsumerState<BoatsTab> {
  List<Boat> _boats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBoats();
  }

  Future<void> _loadBoats() async {
    setState(() => _loading = true);
    try {
      final boats = await ApiService().getBoats();
      setState(() {
        _boats = boats;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: _loadBoats,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _boats.isEmpty
                ? _buildEmpty()
                : _buildBoatList(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE8B84A),
        foregroundColor: const Color(0xFF0A1628),
        onPressed: () => _showAddBoatDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_boat, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('暂无船只'),
        ],
      ),
    );
  }

  Widget _buildBoatList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _boats.length,
      itemBuilder: (context, index) {
        final boat = _boats[index];
        return _BoatCard(
          boat: boat,
          onRefresh: _loadBoats,
          onViewRentals: () => _showRentalsDialog(context, boat),
        );
      },
    );
  }

  void _showAddBoatDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加船只'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '船只名称'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '租金/小时',
                prefixText: 'MOP ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text;
              final price = double.tryParse(priceController.text) ?? 0;
              if (name.isNotEmpty) {
                await ApiService().createBoat(name: name, rentalPrice: price);
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadBoats();
                }
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showRentalsDialog(BuildContext context, Boat boat) async {
    final rentals = await ApiService().getAllRentals();
    final boatRentals = rentals.where((r) => r.boatId == boat.id).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${boat.name} 租借记录'),
        content: SizedBox(
          width: double.maxFinite,
          child: boatRentals.isEmpty
              ? const Text('暂无租借记录')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: boatRentals.length,
                  itemBuilder: (context, index) {
                    final rental = boatRentals[index];
                    return ListTile(
                      title: Text('用户 ID: ${rental.userId}'),
                      subtitle: Text(
                        '时间: ${rental.rentalTime}\n状态: ${rental.status}',
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

class _BoatCard extends StatelessWidget {
  final Boat boat;
  final VoidCallback onRefresh;
  final VoidCallback onViewRentals;

  const _BoatCard({
    required this.boat,
    required this.onRefresh,
    required this.onViewRentals,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF1E8C93).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.directions_boat, color: Color(0xFF1E8C93)),
        ),
        title: Text(boat.name),
        subtitle: Text('MOP ${boat.rentalPrice.toStringAsFixed(2)}/小时'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusBadge(boat.status),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('编辑'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'rentals',
                  child: Row(
                    children: [
                      Icon(Icons.history),
                      SizedBox(width: 8),
                      Text('租借记录'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'status',
                  child: Row(
                    children: [
                      const Icon(Icons.swap_horiz),
                      const SizedBox(width: 8),
                      Text(boat.status == BoatStatus.maintenance ? '设为可用' : '设为维护'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('删除', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) => _handleMenuAction(context, value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BoatStatus status) {
    Color color;
    String text;
    switch (status) {
      case BoatStatus.available:
        color = const Color(0xFF4CAF50);
        text = '可用';
        break;
      case BoatStatus.rented:
        color = Colors.orange;
        text = '已租';
        break;
      case BoatStatus.maintenance:
        color = const Color(0xFFFF6B6B);
        text = '维护';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String value) {
    switch (value) {
      case 'edit':
        _showEditDialog(context);
        break;
      case 'rentals':
        onViewRentals();
        break;
      case 'status':
        _toggleStatus(context);
        break;
      case 'delete':
        _deleteBoat(context);
        break;
    }
  }

  void _showEditDialog(BuildContext context) {
    final nameController = TextEditingController(text: boat.name);
    final priceController = TextEditingController(text: boat.rentalPrice.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑船只'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '船只名称'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '租金/小时',
                prefixText: 'MOP ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text;
              final price = double.tryParse(priceController.text);
              if (name.isNotEmpty && price != null) {
                await ApiService().updateBoat(boat.id, name: name, rentalPrice: price);
                if (context.mounted) {
                  Navigator.pop(context);
                  onRefresh();
                }
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _toggleStatus(BuildContext context) async {
    final newStatus = boat.status == BoatStatus.maintenance
        ? 'available'
        : 'maintenance';
    await ApiService().updateBoat(boat.id, status: newStatus);
    onRefresh();
  }

  void _deleteBoat(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除船只 ${boat.name} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ApiService().deleteBoat(boat.id);
              if (context.mounted) {
                Navigator.pop(context);
                onRefresh();
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: Commit**

```bash
git add frontend/lib/screens/admin/boats_tab.dart
git commit -m "feat: add boats tab with full management"
```

---

### Task 9: 创建 finance_tab.dart

**Files:**
- Create: `frontend/lib/screens/admin/finance_tab.dart`

**Step 1: 创建财务管理 Tab**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../models/index.dart';

class FinanceTab extends ConsumerStatefulWidget {
  const FinanceTab({super.key});

  @override
  ConsumerState<FinanceTab> createState() => _FinanceTabState();
}

class _FinanceTabState extends ConsumerState<FinanceTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _totalBalance = 0;
  List<User> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final balance = await ApiService().getBalance();
      final users = await ApiService().getUsers();
      setState(() {
        _totalBalance = balance;
        _users = users;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildBalanceCard(),
                TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF1E8C93),
                  tabs: const [
                    Tab(text: '充值'),
                    Tab(text: '交易记录'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDepositTab(),
                      _buildRecordsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1628), Color(0xFF15203B)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance_wallet, color: Color(0xFFE8B84A)),
              SizedBox(width: 8),
              Text(
                '总余额',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'MOP ${_totalBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepositTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_add, color: Color(0xFF1E8C93)),
              title: const Text('为用户充值'),
              subtitle: const Text('选择用户并充值'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showUserSelectDialog(context),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance, color: Color(0xFF1E8C93)),
              title: const Text('账户充值'),
              subtitle: const Text('为当前管理员账户充值'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showDepositDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsTab() {
    return FutureBuilder<List<FinanceRecord>>(
      future: ApiService().getFinanceRecords(),
      builder: (context, snapshot) {
        final records = snapshot.data ?? [];
        if (records.isEmpty) {
          return const Center(child: Text('暂无交易记录'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return Card(
              child: ListTile(
                leading: Icon(
                  record.type == 'income'
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: record.type == 'income'
                      ? Colors.green
                      : Colors.red,
                ),
                title: Text(record.description ?? '无描述'),
                subtitle: Text(record.createdAt?.toString() ?? ''),
                trailing: Text(
                  '${record.type == 'income' ? '+' : '-'}MOP ${record.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: record.type == 'income' ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showUserSelectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择用户'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return ListTile(
                title: Text(user.username),
                subtitle: Text('余额: MOP ${user.balance}'),
                onTap: () {
                  Navigator.pop(context);
                  _showUserDepositDialog(context, user);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _showUserDepositDialog(BuildContext context, User user) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('为 ${user.username} 充值'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '充值金额',
            prefixText: 'MOP ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                await ApiService().updateUserBalance(user.id, amount);
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('充值成功')),
                  );
                }
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _showDepositDialog(BuildContext context) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('账户充值'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '充值金额',
            prefixText: 'MOP ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                await ApiService().deposit(amount, '管理员充值');
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadData();
                }
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: Commit**

```bash
git add frontend/lib/screens/admin/finance_tab.dart
git commit -m "feat: add finance tab with deposit and records"
```

---

### Task 10: 创建 activities_tab.dart

**Files:**
- Create: `frontend/lib/screens/admin/activities_tab.dart`

**Step 1: 创建活动管理 Tab**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../models/index.dart';

class ActivitiesTab extends ConsumerStatefulWidget {
  const ActivitiesTab({super.key});

  @override
  ConsumerState<ActivitiesTab> createState() => _ActivitiesTabState();
}

class _ActivitiesTabState extends ConsumerState<ActivitiesTab> {
  List<Activity> _activities = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() => _loading = true);
    try {
      final activities = await ApiService().getActivities();
      setState(() {
        _activities = activities;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: _loadActivities,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _activities.isEmpty
                ? const Center(child: Text('暂无活动'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _activities.length,
                    itemBuilder: (context, index) {
                      final activity = _activities[index];
                      return _ActivityCard(
                        activity: activity,
                        onRefresh: _loadActivities,
                        onViewSignups: () => _showSignupsDialog(context, activity),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE8B84A),
        foregroundColor: const Color(0xFF0A1628),
        onPressed: () => _showAddActivityDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddActivityDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final locationController = TextEditingController();
    final maxController = TextEditingController();
    DateTime startTime = DateTime.now().add(const Duration(days: 1));
    DateTime endTime = DateTime.now().add(const Duration(days: 2));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('发布活动'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: '活动标题'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: '活动描述'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: '活动地点'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: maxController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '人数限制 (0为不限)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text;
              if (title.isNotEmpty) {
                await ApiService().createActivity(
                  title: title,
                  description: descController.text,
                  location: locationController.text,
                  startTime: startTime,
                  endTime: endTime,
                  maxParticipants: int.tryParse(maxController.text) ?? 0,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadActivities();
                }
              }
            },
            child: const Text('发布'),
          ),
        ],
      ),
    );
  }

  void _showSignupsDialog(BuildContext context, Activity activity) async {
    final signups = await ApiService().getActivitySignups(activity.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${activity.title} 报名列表'),
        content: SizedBox(
          width: double.maxFinite,
          child: signups.isEmpty
              ? const Text('暂无报名')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (activity.creatorId != null)
                      ElevatedButton.icon(
                        onPressed: () async {
                          await ApiService().checkinAllActivity(activity.id);
                          if (context.mounted) {
                            Navigator.pop(context);
                            _loadActivities();
                          }
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('一键签到'),
                      ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: signups.length,
                        itemBuilder: (context, index) {
                          final signup = signups[index];
                          return ListTile(
                            title: Text('用户 ID: ${signup.userId}'),
                            trailing: signup.checkIn
                                ? const Icon(Icons.check, color: Colors.green)
                                : const Icon(Icons.close, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback onRefresh;
  final VoidCallback onViewSignups;

  const _ActivityCard({
    required this.activity,
    required this.onRefresh,
    required this.onViewSignups,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isUpcoming = activity.startTime.isAfter(now);
    final isOngoing = activity.startTime.isBefore(now) && activity.endTime.isAfter(now);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              activity.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (activity.location != null)
                  Text('地点: ${activity.location}'),
                Text('时间: ${activity.startTime}'),
                if (activity.maxParticipants > 0)
                  Text('人数限制: ${activity.maxParticipants}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUpcoming)
                  const Chip(
                    label: Text('未开始', style: TextStyle(fontSize: 10)),
                    backgroundColor: Colors.blue,
                  )
                else if (isOngoing)
                  const Chip(
                    label: Text('进行中', style: TextStyle(fontSize: 10)),
                    backgroundColor: Colors.green,
                  )
                else
                  const Chip(
                    label: Text('已结束', style: TextStyle(fontSize: 10)),
                    backgroundColor: Colors.grey,
                  ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'signups',
                      child: Row(
                        children: [
                          Icon(Icons.people),
                          SizedBox(width: 8),
                          Text('报名管理'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('编辑'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('删除', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) => _handleMenuAction(context, value),
                ),
              ],
            ),
          ),
          if (activity.description != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(activity.description!, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String value) {
    switch (value) {
      case 'signups':
        onViewSignups();
        break;
      case 'edit':
        _showEditDialog(context);
        break;
      case 'delete':
        _deleteActivity(context);
        break;
    }
  }

  void _showEditDialog(BuildContext context) {
    final titleController = TextEditingController(text: activity.title);
    final descController = TextEditingController(text: activity.description);
    final locationController = TextEditingController(text: activity.location);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑活动'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: '活动标题'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: '活动描述'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: '活动地点'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService().updateActivity(
                activity.id,
                title: titleController.text,
                description: descController.text,
                location: locationController.text,
              );
              if (context.mounted) {
                Navigator.pop(context);
                onRefresh();
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _deleteActivity(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除活动 "${activity.title}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ApiService().deleteActivity(activity.id);
              if (context.mounted) {
                Navigator.pop(context);
                onRefresh();
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: Commit**

```bash
git add frontend/lib/screens/admin/activities_tab.dart
git commit -m "feat: add activities tab with full management"
```

---

### Task 11: 创建 notices_tab.dart

**Files:**
- Create: `frontend/lib/screens/admin/notices_tab.dart`

**Step 1: 创建公告管理 Tab**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../models/index.dart';

class NoticesTab extends ConsumerStatefulWidget {
  const NoticesTab({super.key});

  @override
  ConsumerState<NoticesTab> createState() => _NoticesTabState();
}

class _NoticesTabState extends ConsumerState<NoticesTab> {
  List<Notice> _notices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    setState(() => _loading = true);
    try {
      final notices = await ApiService().getNotices();
      setState(() {
        _notices = notices;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: _loadNotices,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _notices.isEmpty
                ? const Center(child: Text('暂无公告'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notices.length,
                    itemBuilder: (context, index) {
                      final notice = _notices[index];
                      return _NoticeCard(
                        notice: notice,
                        onRefresh: _loadNotices,
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE8B84A),
        foregroundColor: const Color(0xFF0A1628),
        onPressed: () => _showAddNoticeDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddNoticeDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('发布公告'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: '标题'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: '内容'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text;
              final content = contentController.text;
              if (title.isNotEmpty && content.isNotEmpty) {
                await ApiService().createNotice(title: title, content: content);
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadNotices();
                }
              }
            },
            child: const Text('发布'),
          ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final Notice notice;
  final VoidCallback onRefresh;

  const _NoticeCard({required this.notice, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          notice.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(notice.content, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text(
              notice.createdAt?.toString() ?? '',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteNotice(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final titleController = TextEditingController(text: notice.title);
    final contentController = TextEditingController(text: notice.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑公告'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: '标题'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: '内容'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService().updateNotice(
                notice.id,
                title: titleController.text,
                content: contentController.text,
              );
              if (context.mounted) {
                Navigator.pop(context);
                onRefresh();
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _deleteNotice(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除公告 "${notice.title}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ApiService().deleteNotice(notice.id);
              if (context.mounted) {
                Navigator.pop(context);
                onRefresh();
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: Commit**

```bash
git add frontend/lib/screens/admin/notices_tab.dart
git commit -m "feat: add notices tab with full management"
```

---

### Task 12: 创建 stats_tab.dart

**Files:**
- Create: `frontend/lib/screens/admin/stats_tab.dart`

**Step 1: 创建统计 Tab (需要 fl_chart)**

首先添加依赖：
```yaml
# frontend/pubspec.yaml
dependencies:
  fl_chart: ^0.68.0
```

然后创建 stats_tab.dart：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/api_service.dart';
import '../../models/index.dart';

class StatsTab extends ConsumerStatefulWidget {
  const StatsTab({super.key});

  @override
  ConsumerState<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends ConsumerState<StatsTab> {
  Stats? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    try {
      final stats = await ApiService().getStats();
      setState(() {
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatCards(),
                    const SizedBox(height: 24),
                    _buildRevenueChart(),
                    const SizedBox(height: 24),
                    _buildActivityChart(),
                    const SizedBox(height: 24),
                    _buildBoatUsageChart(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          title: '总用户数',
          value: _stats?.totalUsers.toString() ?? '0',
          icon: Icons.people,
          color: const Color(0xFF1E8C93),
        ),
        _StatCard(
          title: '总活动数',
          value: _stats?.totalActivities.toString() ?? '0',
          icon: Icons.event,
          color: const Color(0xFF9C27B0),
        ),
        _StatCard(
          title: '总船只数',
          value: _stats?.totalBoats.toString() ?? '0',
          icon: Icons.directions_boat,
          color: const Color(0xFF2196F3),
        ),
        _StatCard(
          title: '总收入',
          value: 'MOP ${(_stats?.totalRevenue ?? 0).toStringAsFixed(0)}',
          icon: Icons.attach_money,
          color: const Color(0xFF4CAF50),
        ),
        _StatCard(
          title: '本月收入',
          value: 'MOP ${(_stats?.monthlyRevenue ?? 0).toStringAsFixed(0)}',
          icon: Icons.trending_up,
          color: const Color(0xFFE8B84A),
        ),
        _StatCard(
          title: '活跃用户',
          value: _stats?.activeUsers.toString() ?? '0',
          icon: Icons.person,
          color: const Color(0xFFFF5722),
        ),
      ],
    );
  }

  Widget _buildRevenueChart() {
    final history = _stats?.revenueHistory ?? [];
    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '收入趋势',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < history.length) {
                            return Text(
                              history[index].month.substring(5),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: history.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.revenue);
                      }).toList(),
                      isCurved: true,
                      color: const Color(0xFF1E8C93),
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF1E8C93).withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart() {
    final participation = _stats?.activityParticipation ?? [];
    if (participation.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '活动参与统计',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < participation.length) {
                            return Text(
                              participation[index].month.substring(5),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: participation.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.count.toDouble(),
                          color: const Color(0xFFE8B84A),
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoatUsageChart() {
    final usage = _stats?.boatUsage ?? [];
    if (usage.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '船只使用率',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: usage.map((e) {
                    final colors = [
                      const Color(0xFF1E8C93),
                      const Color(0xFFE8B84A),
                      const Color(0xFFFF6B6B),
                      const Color(0xFF4CAF50),
                      const Color(0xFF2196F3),
                    ];
                    return PieChartSectionData(
                      value: e.rentalCount.toDouble(),
                      title: e.boatName,
                      color: colors[usage.indexOf(e) % colors.length],
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 2: Commit**

```bash
git add frontend/lib/screens/admin/stats_tab.dart
git commit -m "feat: add stats tab with charts"
```

---

### Task 13: 重构 admin_screen.dart

**Files:**
- Modify: `frontend/lib/screens/admin/admin_screen.dart`

**Step 1: 移除内联 Tab 代码，改为导入**

```dart
import 'users_tab.dart';
import 'finance_tab.dart';
import 'boats_tab.dart';
import 'activities_tab.dart';
import 'notices_tab.dart';
import 'stats_tab.dart';
```

更新 TabBar 和 TabBarView：

```dart
bottom: const TabBar(
  labelColor: Color(0xFF1E8C93),
  unselectedLabelColor: Colors.black54,
  indicatorColor: Color(0xFFE8B84A),
  tabs: [
    Tab(text: '用户'),
    Tab(text: '财务'),
    Tab(text: '船只'),
    Tab(text: '活动'),
    Tab(text: '公告'),
    Tab(text: '统计'),
  ],
),

// ...

body: TabBarView(
  children: [
    const UsersTab(),
    const FinanceTab(),
    const BoatsTab(),
    const ActivitiesTab(),
    const NoticesTab(),
    const StatsTab(),
  ],
),
```

**Step 2: Commit**

```bash
git add frontend/lib/screens/admin/admin_screen.dart
git commit -m "refactor: split admin tabs into separate files"
```

---

### Task 14: 添加财务记录模型

**Files:**
- Modify: `frontend/lib/models/index.dart`

**Step 1: 添加 FinanceRecord 模型**

```dart
class FinanceRecord {
  final int id;
  final double amount;
  final String type; // 'income' or 'expense'
  final String? description;
  final int? userId;
  final DateTime? createdAt;

  FinanceRecord({
    required this.id,
    required this.amount,
    required this.type,
    this.description,
    this.userId,
    this.createdAt,
  });

  factory FinanceRecord.fromJson(Map<String, dynamic> json) {
    return FinanceRecord(
      id: json['id'],
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? 'income',
      description: json['description'],
      userId: json['user_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}

class BoatRental {
  final int id;
  final int boatId;
  final int userId;
  final DateTime rentalTime;
  final DateTime? returnTime;
  final String status;

  BoatRental({
    required this.id,
    required this.boatId,
    required this.userId,
    required this.rentalTime,
    this.returnTime,
    required this.status,
  });

  factory BoatRental.fromJson(Map<String, dynamic> json) {
    return BoatRental(
      id: json['id'],
      boatId: json['boat_id'],
      userId: json['user_id'],
      rentalTime: DateTime.parse(json['rental_time']),
      returnTime: json['return_time'] != null
          ? DateTime.parse(json['return_time'])
          : null,
      status: json['status'] ?? 'active',
    );
  }
}
```

**Step 2: Commit**

```bash
git add frontend/lib/models/index.dart
git commit -m "feat: add FinanceRecord and BoatRental models"
```

---

## 计划完成

**Plan complete and saved to `docs/plans/2026-02-22-admin-dashboard-design.md`. Two execution options:**

1. **Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration

2. **Parallel Session (separate)** - Open new session with executing_plans, batch execution with checkpoints

Which approach?
