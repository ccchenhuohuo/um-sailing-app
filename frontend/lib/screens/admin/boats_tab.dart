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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载船只失败: $e')),
        );
      }
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
                try {
                  await ApiService().createBoat(name: name, rentalPrice: price);
                  if (context.mounted) {
                    Navigator.pop(context);
                    _loadBoats();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('添加成功')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('添加失败: $e')),
                    );
                  }
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
    try {
      final rentals = await ApiService().getAllRentals();
      final boatRentals = rentals.where((r) => r.boatId == boat.id).toList();

      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('${boat.name} 租借记录'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: boatRentals.isEmpty
                ? const Center(child: Text('暂无租借记录'))
                : ListView.builder(
                    itemCount: boatRentals.length,
                    itemBuilder: (context, index) {
                      final rental = boatRentals[index];
                      return ListTile(
                        title: Text('用户 ID: ${rental.userId}'),
                        subtitle: Text(
                          '租借时间: ${rental.rentalTime.toString().substring(0, 19)}\n状态: ${rental.status}',
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
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取记录失败: $e')),
        );
      }
    }
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
            color: const Color(0xFF1E8C93).withValues(alpha: 0.15),
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
        color: color.withValues(alpha: 0.15),
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
                try {
                  await ApiService().updateBoat(boat.id, name: name, rentalPrice: price);
                  if (context.mounted) {
                    Navigator.pop(context);
                    onRefresh();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('更新成功')),
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
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _toggleStatus(BuildContext context) {
    final isMaintenance = boat.status == BoatStatus.maintenance;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认'),
        content: Text(isMaintenance
            ? '确定要将船只 "${boat.name}" 设为可用吗？'
            : '确定要将船只 "${boat.name}" 设为维护状态吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final newStatus = isMaintenance ? 'available' : 'maintenance';
              try {
                await ApiService().updateBoat(boat.id, status: newStatus);
                onRefresh();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('状态更新成功')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('更新状态失败: $e')),
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
              try {
                await ApiService().deleteBoat(boat.id);
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
