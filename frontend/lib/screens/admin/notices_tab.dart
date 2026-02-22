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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载公告失败: $e')),
        );
      }
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
                try {
                  await ApiService().createNotice(title: title, content: content);
                  if (context.mounted) {
                    Navigator.pop(context);
                    _loadNotices();
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
              notice.createdAt.toString().substring(0, 19),
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
              try {
                await ApiService().updateNotice(
                  notice.id,
                  title: titleController.text,
                  content: contentController.text,
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
              try {
                await ApiService().deleteNotice(notice.id);
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
