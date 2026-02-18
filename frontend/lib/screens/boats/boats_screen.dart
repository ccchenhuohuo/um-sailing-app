import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/boat.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';
import '../../widgets/ocean/ocean_background.dart';

class BoatsScreen extends StatelessWidget {
  const BoatsScreen({super.key});

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
                Text(
                  '船只管理',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          body: const BoatsGridView(),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFFE8B84A),
            foregroundColor: const Color(0xFF0A1628),
            onPressed: () => _showAddBoatDialog(context),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  void _showAddBoatDialog(BuildContext context) {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('添加船只', style: TextStyle(color: Colors.black)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField(
                controller: nameController,
                label: '船只名称 *',
                icon: Icons.directions_boat,
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(
                controller: typeController,
                label: '船只类型',
                icon: Icons.category,
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(
                controller: priceController,
                label: '租金/小时',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(
                controller: descController,
                label: '描述',
                icon: Icons.description,
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8B84A),
              foregroundColor: const Color(0xFF0A1628),
            ),
            onPressed: () async {
              final name = nameController.text;
              final price = double.tryParse(priceController.text) ?? 0;
              if (name.isNotEmpty) {
                await ApiService().createBoat(
                  name: name,
                  type: typeController.text.isEmpty ? null : typeController.text,
                  rentalPrice: price,
                  description: descController.text.isEmpty ? null : descController.text,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('添加成功')),
                  );
                }
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: Icon(icon, color: const Color(0xFF1E8C93)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E8C93), width: 2),
        ),
      ),
    );
  }
}

class BoatsGridView extends StatelessWidget {
  const BoatsGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Boat>>(
      future: ApiService().getBoats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF1E8C93)));
        }

        final boats = snapshot.data ?? [];
        if (boats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_boat, size: 64, color: Colors.black26),
                const SizedBox(height: 16),
                const Text('暂无船只', style: TextStyle(fontSize: 16, color: Colors.black54)),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: boats.length,
          itemBuilder: (context, index) {
            final boat = boats[index];
            return BoatCard(boat: boat);
          },
        );
      },
    );
  }
}

class BoatCard extends StatelessWidget {
  final Boat boat;

  const BoatCard({super.key, required this.boat});

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      onTap: () => _showDetail(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _getBackgroundColor().withOpacity(0.8),
                    _getBackgroundColor().withOpacity(0.6),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: boat.imageUrl != null
                  ? null
                  : Center(
                      child: Icon(
                        Icons.directions_boat,
                        size: 60,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        boat.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusBadge(),
                  ],
                ),
                if (boat.type != null)
                  Text(
                    boat.type!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'MOP ${boat.rentalPrice.toStringAsFixed(2)}/h',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE8B84A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (boat.status) {
      case BoatStatus.available:
        return const Color(0xFF1E8C93);
      case BoatStatus.rented:
        return Colors.orange;
      case BoatStatus.maintenance:
        return const Color(0xFFFF6B6B);
    }
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;
    switch (boat.status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    boat.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
            if (boat.type != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(boat.type!, style: const TextStyle(color: Colors.black54)),
              ),
            const SizedBox(height: 20),
            if (boat.description != null) ...[
              const Text('描述', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 8),
              Text(boat.description!, style: const TextStyle(color: Colors.black87)),
              const SizedBox(height: 20),
            ],
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A1628), Color(0xFF15203B)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.attach_money, color: Color(0xFFE8B84A), size: 28),
                  const SizedBox(width: 8),
                  Text(
                    '${boat.rentalPrice.toStringAsFixed(2)} / 小时',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow(Icons.access_time, '创建时间', DateFormat('yyyy-MM-dd').format(boat.createdAt)),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: boat.status == BoatStatus.available
                          ? const Color(0xFFE8B84A)
                          : Colors.grey,
                      foregroundColor: const Color(0xFF0A1628),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: boat.status == BoatStatus.available
                        ? () async {
                            try {
                              await ApiService().rentBoat(boat.id);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('租船成功')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('租船失败: $e')),
                              );
                            }
                          }
                        : null,
                    child: const Text('立即租船'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E8C93),
                      side: const BorderSide(color: Color(0xFF1E8C93)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('归还'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E8C93).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF1E8C93)),
          ),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}
