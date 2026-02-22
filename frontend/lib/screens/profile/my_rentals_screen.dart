import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/boat_rental.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';
import '../../widgets/ocean/ocean_background.dart';

class MyRentalsScreen extends ConsumerStatefulWidget {
  const MyRentalsScreen({super.key});

  @override
  ConsumerState<MyRentalsScreen> createState() => _MyRentalsScreenState();
}

class _MyRentalsScreenState extends ConsumerState<MyRentalsScreen> {
  final _apiService = ApiService();
  late Future<List<BoatRental>> _rentalsFuture;

  @override
  void initState() {
    super.initState();
    _loadRentals();
  }

  void _loadRentals() {
    _rentalsFuture = _apiService.getMyRentals();
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
                Icon(Icons.directions_boat, color: Color(0xFF1E8C93)),
                SizedBox(width: 10),
                Text('租船记录', style: TextStyle(color: Colors.black)),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: FutureBuilder<List<BoatRental>>(
            future: _rentalsFuture,
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
                            _loadRentals();
                          });
                        },
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                );
              }

              final rentals = snapshot.data ?? [];
              if (rentals.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_boat, size: 64, color: Colors.black26),
                      const SizedBox(height: 16),
                      const Text(
                        '暂无租船记录',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  final future = _apiService.getMyRentals();
                  setState(() {
                    _rentalsFuture = future;
                  });
                  await future;
                },
                color: const Color(0xFF1E8C93),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rentals.length,
                  itemBuilder: (context, index) {
                    final rental = rentals[index];
                    return _buildRentalCard(rental);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRentalCard(BoatRental rental) {
    final boat = rental.boat;
    final isActive = rental.isActive;
    final statusColor = isActive ? Colors.orange : const Color(0xFF4CAF50);
    final statusText = rental.statusText;

    return WhiteCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和状态
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E8C93).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.directions_boat,
                        color: Color(0xFF1E8C93),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            boat?.name ?? '未知船只',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          if (boat?.type != null)
                            Text(
                              boat!.type!,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 租借时间信息
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.black54),
                    const SizedBox(width: 8),
                    const Text(
                      '租借时间:',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(rental.rentalTime),
                      style: const TextStyle(color: Colors.black87, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.event_available, size: 16, color: Colors.black54),
                    const SizedBox(width: 8),
                    const Text(
                      '归还时间:',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const Spacer(),
                    Text(
                      rental.returnTime != null
                          ? DateFormat('yyyy-MM-dd HH:mm').format(rental.returnTime!)
                          : '未归还',
                      style: TextStyle(
                        color: rental.returnTime != null ? Colors.black87 : Colors.orange,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.timer, size: 16, color: Colors.black54),
                    const SizedBox(width: 8),
                    const Text(
                      '租借时长:',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const Spacer(),
                    Text(
                      '${rental.rentalHours.toStringAsFixed(1)} 小时',
                      style: const TextStyle(color: Colors.black87, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 费用信息
          if (rental.rentalFee != null || isActive) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '租金费用:',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                Text(
                  rental.rentalFee != null
                      ? 'MOP ${rental.rentalFee!.toStringAsFixed(2)}'
                      : 'MOP ${(rental.rentalHours * (boat?.rentalPrice ?? 0)).toStringAsFixed(2)} (待结算)',
                  style: TextStyle(
                    color: isActive ? Colors.orange : const Color(0xFF4CAF50),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],

          // 归还按钮
          if (isActive) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _returnBoat(rental),
                child: const Text('归还船只'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _returnBoat(BoatRental rental) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认归还'),
        content: Text('确定要归还船只 "${rental.boat?.name ?? '未知船只'}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _apiService.returnBoat(rental.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('归还成功')),
                  );
                  setState(() {
                    _loadRentals();
                  });
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('归还失败，请稍后重试')),
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
}
