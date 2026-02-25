import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/view/trainer/chats/trainer_requests_view.dart';
import 'package:catch_ride/view/trainer/chats/single_chat_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrainerChatsView extends StatelessWidget {
  const TrainerChatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> chats = [
      {
        'name': 'Lana Steiner',
        'message': 'Thanks so much, happy with that.',
        'time': '2 mins ago',
        'image': AppConstants.dummyImageUrl,
        'isUnread': true,
      },
      {
        'name': 'Demi Wikinson',
        'message': 'Got you a coffee',
        'time': '2 mins ago',
        'image': AppConstants.dummyImageUrl,
        'isUnread': false,
      },
      {
        'name': 'Candice Wu',
        'message': 'Great to see you again!',
        'time': '3 hours ago',
        'image': AppConstants.dummyImageUrl,
        'isUnread': false,
      },
      {
        'name': 'Natali Craig',
        'message': 'We should ask Oli about this...',
        'time': '6 hours ago',
        'image': AppConstants.dummyImageUrl,
        'isUnread': false,
      },
      {
        'name': 'Drew Cano',
        'message': 'Okay, see you then.',
        'time': '12 hours ago',
        'image': AppConstants.dummyImageUrl,
        'isUnread': false,
      },
      {
        'name': 'Drew Cano',
        'message': 'Okay, see you then.',
        'time': '12 hours ago',
        'image': AppConstants.dummyImageUrl,
        'isUnread': false,
      },
      {
        'name': 'Drew Cano',
        'message': 'Okay, see you then.',
        'time': '12 hours ago',
        'image': AppConstants.dummyImageUrl,
        'isUnread': false,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const CommonText(
          'Inbox',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Get.to(() => const TrainerRequestsView()),
            icon: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            label: const CommonText(
              'Requests',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border.withOpacity(0.5), height: 1),
        ),
      ),
      body: ListView.separated(
        itemCount: chats.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          indent: 80,
          endIndent: 16,
          color: AppColors.border,
        ),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return _buildChatItem(context, chat);
        },
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, Map<String, dynamic> chat) {
    return GestureDetector(
      onTap: () => Get.to(
        () => SingleChatView(name: chat['name'], image: chat['image']),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(chat['image']),
          ),
          title: Row(
            children: [
              CommonText(
                chat['name'],
                fontSize: AppTextSizes.size16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              CommonText(
                chat['time'],
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: CommonText(
              chat['message'],
              fontSize: 14,
              color: AppColors.textSecondary,
              maxLines: 1,
            ),
          ),
          trailing: chat['isUnread']
              ? Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF13CA8B),
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
