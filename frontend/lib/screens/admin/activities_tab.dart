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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载活动失败: $e')),
        );
      }
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
                try {
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('发布成功')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('发布失败: $e')),
                    );
                  }
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
    try {
      final signups = await ApiService().getActivitySignups(activity.id);

      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('${activity.title} 报名列表'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: signups.isEmpty
                ? const Center(child: Text('暂无报名'))
                : ListView.builder(
                    itemCount: signups.length,
                    itemBuilder: (context, index) {
                      final signup = signups[index];
                      return ListTile(
                        title: Text('用户 ID: ${signup.userId}'),
                        trailing: signup.checkedIn
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.close, color: Colors.grey),
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
          SnackBar(content: Text('获取报名列表失败: $e')),
        );
      }
    }
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
                Text('时间: ${activity.startTime.toString().substring(0, 16)}'),
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
    final descController = TextEditingController(text: activity.description ?? '');
    final locationController = TextEditingController(text: activity.location ?? '');

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
              try {
                await ApiService().updateActivity(
                  activity.id,
                  title: titleController.text,
                  description: descController.text,
                  location: locationController.text,
                );
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
              try {
                await ApiService().deleteActivity(activity.id);
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
