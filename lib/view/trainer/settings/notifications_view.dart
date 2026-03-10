import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        'name': 'Jordan Lee',
        'time': 'Just now',
        'message': 'Sent you a booking request',
        'image': 'https://i.pravatar.cc/150?u=jordan',
        'isUnread': true,
      },
      {
        'name': 'Maya Chen',
        'time': '3 mins ago',
        'message': 'Added Chris Morgan to the project team',
        'image': 'https://i.pravatar.cc/150?u=maya',
        'isUnread': true,
      },
      {
        'name': 'Alex Johnson',
        'time': '3 mins ago',
        'message': 'Added Chris Morgan to the project team',
        'image': 'https://i.pravatar.cc/150?u=alex',
        'isUnread': true,
      },
      {
        'name': 'Sophie Turner',
        'time': '4 hours ago',
        'message': 'Commented on the Product launch',
        'image': 'https://i.pravatar.cc/150?u=sophie',
        'isUnread': true,
      },
      {
        'name': 'Sophie Turner',
        'time': '4 hours ago',
        'message': 'Was assigned to the Product launch',
        'image': 'https://i.pravatar.cc/150?u=sophie',
        'isUnread': false,
      },
      {
        'name': 'Liam Smith',
        'time': '7 hours ago',
        'message': 'Created 5 tasks for the Product launch',
        'image': 'https://i.pravatar.cc/150?u=liam',
        'isUnread': false,
      },
      {
        'name': 'Liam Smith',
        'time': '7 hours ago',
        'message': 'Invited Maya Chen to the project team',
        'image': 'https://i.pravatar.cc/150?u=liam',
        'isUnread': false,
      },
    ];

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
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    bool isUnread = notification['isUnread'] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
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
          CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(notification['image']),
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
                        notification['name'],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CommonText(
                      notification['time'],
                      fontSize: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                CommonText(
                  notification['message'],
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isUnread)
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
    );
  }
}
