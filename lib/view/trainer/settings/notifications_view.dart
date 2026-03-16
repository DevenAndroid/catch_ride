import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/notification_controller.dart';
import 'package:catch_ride/models/notification_model.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.put(NotificationController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Notifications',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        actions: [
          Obx(() => controller.unreadCount.value > 0 
            ? TextButton(
                onPressed: controller.markAllAsRead,
                child: const CommonText(
                  'Mark all as read',
                  fontSize: 14,
                  color: AppColors.linkBlue,
                  fontWeight: FontWeight.w600,
                ),
              )
            : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.fetchNotifications,
            child: ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                const Center(
                  child: CommonText(
                    'No notifications yet',
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchNotifications,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return _buildNotificationItem(notification, controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification, NotificationController controller) {
    return GestureDetector(
      onTap: () {
        if (!notification.read) {
          controller.markAsRead(notification.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notification.read ? Colors.white : AppColors.background.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: notification.read ? AppColors.border.withValues(alpha: 0.5) : AppColors.primary.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getNotificationColor(notification.type).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: _getNotificationColor(notification.type),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: CommonText(
                          notification.title,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CommonText(
                        _formatDate(notification.createdAt),
                        fontSize: 12,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  CommonText(
                    notification.message,
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!notification.read)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF17B26A), // Brand Green
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'booking': return Icons.calendar_today_rounded;
      case 'message': return Icons.chat_bubble_outline_rounded;
      case 'approval': return Icons.check_circle_outline_rounded;
      case 'reminder': return Icons.alarm_rounded;
      case 'payment': return Icons.payments_outlined;
      case 'review': return Icons.star_border_rounded;
      default: return Icons.notifications_none_rounded;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'booking': return Colors.blue;
      case 'message': return Colors.green;
      case 'approval': return AppColors.successPrimary;
      case 'reminder': return Colors.orange;
      case 'payment': return Colors.purple;
      case 'review': return Colors.amber;
      default: return AppColors.primary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('dd MMM').format(date);
    }
  }
}
