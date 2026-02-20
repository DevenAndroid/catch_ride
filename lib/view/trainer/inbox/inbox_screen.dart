import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/trainer/inbox/chat_detail_screen.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data for MVP check
    final List<Map<String, dynamic>> threads = [
      {
        'name': 'Sarah (Barn Manager)',
        'msg': 'New booking request for Thunderbolt',
        'time': '10:30 AM',
        'unread': true,
        'image': 'https://via.placeholder.com/150',
      },
      {
        'name': 'Mike (Trainer)',
        'msg': 'Thanks for the update!',
        'time': 'Yesterday',
        'unread': false,
        'image': 'https://via.placeholder.com/150',
      },
    ];

    // Toggle this to test Empty State
    // final List<Map<String, dynamic>> threads = [];

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: threads.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              itemCount: threads.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final thread = threads[index];
                bool isUnread = thread['unread'];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.grey300,
                    backgroundImage: NetworkImage(thread['image']),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        thread['name'],
                        style: isUnread
                            ? AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              )
                            : AppTextStyles.titleMedium,
                      ),
                      Text(thread['time'], style: AppTextStyles.bodySmall),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: Text(
                          thread['msg'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: isUnread
                              ? AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.deepNavy,
                                  fontWeight: FontWeight.w600,
                                )
                              : AppTextStyles.bodyMedium,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.deepNavy,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '1', // Count could be dynamic
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    Get.to(() => ChatDetailScreen(userName: thread['name']));
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Normal 'Start New Conversation' for Trainers
          Get.snackbar('New Message', 'Select a contact to message');
        },
        backgroundColor: AppColors.deepNavy,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.grey400),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Messages will appear here when you connect with vendors or trainers.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
