import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/constant/app_constants.dart';
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
        'image': AppConstants.dummyImageUrl,
        'isUnread': true,
      },
      {
        'name': 'Maya Chen',
        'time': '3 mins ago',
        'message': 'Added Chris Morgan to the project team',
        'image': AppConstants.dummyImageUrl,
        'isUnread': true,
      },
      {
        'name': 'Alex Johnson',
        'time': '3 mins ago',
        'message': 'Added Chris Morgan to the project team',
        'image': AppConstants.dummyImageUrl,
        'isUnread': true,
      },
      {
        'name': 'Sophie Turner',
        'time': '4 hours ago',
        'message': 'Commented on the Product launch',
        'image': AppConstants.dummyImageUrl,
        'isUnread': true,
      },
      {
        'name': 'Sophie Turner',
        'time': '4 hours ago',
        'message': 'Was assigned to the Product launch',
        'image': AppConstants.dummyImageUrl,
        'isUnread': false,
      },
      {
        'name': 'Liam Smith',
        'time': '7 hours ago',
        'message': 'Created 5 tasks for the Product launch',
        'image': AppConstants.dummyImageUrl,
        'isUnread': false,
      },
      {
        'name': 'Liam Smith',
        'time': '7 hours ago',
        'message': 'Invited Maya Chen to the project team',
        'image': AppConstants.dummyImageUrl,
        'isUnread': false,
      },
      {
        'name': 'Ella White',
        'time': '13 hours ago',
        'message': 'Created the project Product launch',
        'image': AppConstants.dummyImageUrl,
        'isUnread': false,
        'isOnline': true,
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
          fontSize: AppTextSizes.size18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.border.withOpacity(0.5),
            height: 1.0,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(notification['image']),
              ),
              if (notification['isOnline'] ?? false)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF13CA8B),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CommonText(
                      notification['name'],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 8),
                    CommonText(
                      notification['time'],
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                CommonText(
                  notification['message'],
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (notification['isUnread'] ?? false)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8),
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF13CA8B),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
