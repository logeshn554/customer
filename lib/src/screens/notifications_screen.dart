import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _isLoading = true;
  List<dynamic> _notifications = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final client = ref.read(apiClientProvider);
      final res = await client.getNotifications(role: 'CUSTOMER');
      if (mounted) {
        setState(() {
          _notifications = (res['notifications'] as List<dynamic>?) ?? [];
          _unreadCount = (res['unreadCount'] as num?)?.toInt() ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllRead() async {
    try {
      final client = ref.read(apiClientProvider);
      await client.markAllNotificationsRead(role: 'CUSTOMER');
      _loadNotifications();
    } catch (_) {}
  }

  Future<void> _markRead(String id) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.markNotificationRead(id, role: 'CUSTOMER');
      _loadNotifications();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllGoColors.background,
      appBar: AllGoAppBar(
        title: 'Notifications',
        showBackButton: true,
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read', style: TextStyle(color: AllGoColors.primary, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none, size: 56, color: AllGoColors.textTertiary),
                          const SizedBox(height: 12),
                          const Text('No notifications yet', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          const Text('Booking updates and alerts will appear here.', style: TextStyle(color: AllGoColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      itemBuilder: (ctx, idx) {
                        final n = _notifications[idx];
                        final isRead = n['is_read'] == true;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isRead ? AllGoColors.surface : AllGoColors.primaryLight.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isRead ? AllGoColors.divider : AllGoColors.primary.withOpacity(0.3)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: isRead ? AllGoColors.divider : AllGoColors.primary.withOpacity(0.2),
                                child: Icon(
                                  n['category'] == 'PAYMENT' ? Icons.payment : Icons.notifications,
                                  size: 18,
                                  color: isRead ? AllGoColors.textTertiary : AllGoColors.primaryDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n['title']?.toString() ?? 'Update',
                                      style: TextStyle(
                                        fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                        fontSize: 14,
                                        color: AllGoColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      n['body']?.toString() ?? '',
                                      style: const TextStyle(fontSize: 12, color: AllGoColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isRead)
                                IconButton(
                                  icon: const Icon(Icons.check_circle_outline, size: 18, color: AllGoColors.primary),
                                  onPressed: () => _markRead(n['id'].toString()),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
