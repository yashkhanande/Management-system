import 'package:flutter/material.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/notification_tile.dart';
import 'package:managementt/controller/auth_controller.dart';
import 'package:managementt/model/app_notification.dart';
import 'package:managementt/service/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationService _notificationService = NotificationService();
  late Future<List<AppNotification>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _loadNotifications();
  }

  Future<List<AppNotification>> _loadNotifications() {
    final memberId = AuthController.to.currentUserId.value.trim();
    if (memberId.isEmpty) {
      return Future.value(const <AppNotification>[]);
    }
    return _notificationService.getNotifications(memberId);
  }

  Future<void> _refresh() async {
    final next = _loadNotifications();
    setState(() {
      _notificationsFuture = next;
    });
    await next;
  }

  NotificationTileData _toTileData(AppNotification notification) {
    final type = notification.eventType.trim().toUpperCase();

    IconData icon;
    Color iconBackground;
    String title;

    switch (type) {
      case 'NEW_TASK_CREATION':
        icon = Icons.assignment_turned_in_outlined;
        iconBackground = const Color(0xFF2563EB);
        title = 'New Task Created';
        break;
      case 'REMARK_SECTION':
        icon = Icons.chat_bubble_outline;
        iconBackground = const Color(0xFF8B5CF6);
        title = 'New Remark';
        break;
      case 'REVIEW_REQUEST':
        icon = Icons.rate_review_outlined;
        iconBackground = const Color(0xFF0EA5A4);
        title = 'Review Request';
        break;
      case 'OVERDUE_WARNING':
        icon = Icons.warning_amber_rounded;
        iconBackground = const Color(0xFFEF4444);
        title = 'Overdue Warning';
        break;
      case 'PROJECT_READY_TO_WORK':
        icon = Icons.play_circle_outline;
        iconBackground = const Color(0xFF10B981);
        title = 'Project Ready';
        break;
      default:
        icon = Icons.notifications_none_rounded;
        iconBackground = const Color(0xFFFF7A1A);
        title = 'Notification';
    }

    return NotificationTileData(
      title: title,
      message: notification.message.isNotEmpty
          ? notification.message
          : 'You have a new update.',
      timeLabel: _formatTimeLabel(notification.time),
      icon: icon,
      iconBackground: iconBackground,
      isUnread: true,
    );
  }

  String _formatTimeLabel(DateTime? value) {
    if (value == null) return 'Unknown time';

    final now = DateTime.now();
    final diff = now.difference(value);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    final mm = value.month.toString().padLeft(2, '0');
    final dd = value.day.toString().padLeft(2, '0');
    final yyyy = value.year.toString();
    return '$dd/$mm/$yyyy';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Notifications'),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: FutureBuilder<List<AppNotification>>(
            future: _notificationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Failed to load notifications',
                            style: TextStyle(
                              color: Color(0xFF111827),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _refresh,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final notifications = snapshot.data ?? const <AppNotification>[];
              final tiles = notifications.map(_toTileData).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Recent Updates',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.info,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${tiles.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: tiles.isEmpty
                          ? SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height: 260,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: AppColors.info.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.inbox_outlined,
                                          color: AppColors.info,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'No notifications',
                                        style: TextStyle(
                                          color: Color(0xFF111827),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        "You're all caught up!",
                                        style: TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: tiles.length,
                              itemBuilder: (context, index) {
                                return NotificationTile(
                                  notification: tiles[index],
                                );
                              },
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
