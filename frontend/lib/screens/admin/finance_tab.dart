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
                  unselectedLabelColor: Colors.black54,
                  indicatorColor: const Color(0xFFE8B84A),
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
    return FutureBuilder<List<TransactionRecord>>(
      future: ApiService().getTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('加载失败: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

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
                  record.isDeposit
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: record.isDeposit
                      ? Colors.green
                      : Colors.red,
                ),
                title: Text(record.description ?? '无描述'),
                subtitle: Text(record.createdAt.toString().substring(0, 19)),
                trailing: Text(
                  '${record.isDeposit ? '+' : '-'}MOP ${record.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: record.isDeposit ? Colors.green : Colors.red,
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
          height: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return ListTile(
                title: Text(user.username),
                subtitle: Text('余额: MOP ${user.balance.toStringAsFixed(2)}'),
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
                try {
                  await ApiService().updateUserBalance(user.id, amount);
                  if (context.mounted) {
                    Navigator.pop(context);
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('充值成功')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('充值失败: $e')),
                    );
                  }
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
                try {
                  await ApiService().deposit(amount, '管理员充值');
                  if (context.mounted) {
                    Navigator.pop(context);
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('充值成功')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('充值失败: $e')),
                    );
                  }
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
