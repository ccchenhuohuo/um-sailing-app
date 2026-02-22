import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/index.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';
import '../../widgets/ocean/ocean_background.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends ConsumerState<TransactionHistoryScreen> {
  final _apiService = ApiService();
  late Future<List<TransactionRecord>> _transactionsFuture;
  String _filter = 'all'; // all, deposit, payment

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    _transactionsFuture = _apiService.getTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.whiteCardTheme,
      child: OceanBackground(
        enableWave: true,
        enableParticles: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long, color: Color(0xFF1E8C93)),
                SizedBox(width: 10),
                Text('交易记录', style: TextStyle(color: Colors.black)),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: Column(
            children: [
              // 筛选选项
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildFilterChip('全部', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('充值', 'deposit'),
                    const SizedBox(width: 8),
                    _buildFilterChip('消费', 'payment'),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<TransactionRecord>>(
                  future: _transactionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFF1E8C93)),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              '加载失败，请稍后重试',
                              style: const TextStyle(color: Colors.black54),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _loadTransactions();
                                });
                              },
                              child: const Text('重试'),
                            ),
                          ],
                        ),
                      );
                    }

                    var transactions = snapshot.data ?? [];

                    // 应用筛选
                    if (_filter != 'all') {
                      transactions = transactions.where((t) {
                        if (_filter == 'deposit') return t.isDeposit;
                        if (_filter == 'payment') return t.isPayment;
                        return true;
                      }).toList();
                    }

                    if (transactions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, size: 64, color: Colors.black26),
                            const SizedBox(height: 16),
                            Text(
                              _filter == 'all' ? '暂无交易记录' : '暂无${_filter == 'deposit' ? '充值' : '消费'}记录',
                              style: const TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        final future = _apiService.getTransactions();
                        setState(() {
                          _transactionsFuture = future;
                        });
                        await future;
                      },
                      color: const Color(0xFF1E8C93),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          return _buildTransactionCard(transaction);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filter = value;
        });
      },
      selectedColor: const Color(0xFF1E8C93).withValues(alpha: 0.2),
      checkmarkColor: const Color(0xFF1E8C93),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF1E8C93) : Colors.black54,
      ),
    );
  }

  Widget _buildTransactionCard(TransactionRecord transaction) {
    final isDeposit = transaction.isDeposit;
    final amountColor = isDeposit ? const Color(0xFF4CAF50) : Colors.red;
    final amountPrefix = isDeposit ? '+' : '-';
    final icon = isDeposit ? Icons.add_circle : Icons.remove_circle;
    final iconColor = isDeposit ? const Color(0xFF4CAF50) : Colors.red;
    final typeText = isDeposit ? '充值' : '消费';

    return WhiteCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (transaction.description != null)
                  Text(
                    transaction.description!,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(transaction.createdAt),
                  style: const TextStyle(color: Colors.black38, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '$amountPrefix MOP ${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: amountColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
