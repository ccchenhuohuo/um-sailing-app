import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../models/index.dart';

class UsersTab extends ConsumerStatefulWidget {
  const UsersTab({super.key});

  @override
  ConsumerState<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends ConsumerState<UsersTab> {
  List<User> _users = [];
  List<User> _filteredUsers = [];
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
        _filteredUsers = _searchQuery.isEmpty
            ? users
            : users.where((u) => u.username.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载用户失败: $e')),
        );
      }
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _filteredUsers = value.isEmpty
          ? _users
          : _users.where((u) => u.username.toLowerCase().contains(value.toLowerCase())).toList();
    });
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: _onSearchChanged,
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
            user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
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
                  color: const Color(0xFFE8B84A).withValues(alpha: 0.2),
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
            _DetailRow(label: '余额', value: 'MOP ${user.balance.toStringAsFixed(2)}'),
            _DetailRow(label: '角色', value: user.isAdmin ? '管理员' : '普通用户'),
            _DetailRow(label: '注册时间', value: user.createdAt.toString().substring(0, 19)),
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
                  try {
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
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('更新失败: $e')),
                      );
                    }
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
              try {
                await ApiService().updateUserAdmin(user.id, isAdmin: true);
                if (context.mounted) {
                  Navigator.pop(context);
                  onRefresh();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('设置成功')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('设置失败: $e')),
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
              try {
                await ApiService().deleteUser(user.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  onRefresh();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('删除成功')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('删除失败: $e')),
                  );
                }
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
