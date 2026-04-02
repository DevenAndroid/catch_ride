import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/models/message_model.dart';
import 'package:catch_ride/view/trainer/chats/single_chat_view.dart';
import 'package:catch_ride/view/vendor/groom/chat/requests_view.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class GroomChatView extends StatelessWidget {
  GroomChatView({super.key});

  final controller = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const CommonText('Inbox', fontSize: AppTextSizes.size24, fontWeight: FontWeight.bold),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: GestureDetector(
                onTap: () => Get.to(() => const RequestsView()),
                child: Row(
                  children: const [
                    CircleAvatar(radius: 4, backgroundColor: Colors.blue),
                    SizedBox(width: 8),
                    CommonText('Requests', color: Colors.blue, fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingConversations.value && controller.conversations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filter: Active conversations only + Trainers/Barn Managers only
        final filteredChats = controller.conversations.where((c) {
          final otherUserRole = c.otherUser?.role?.toLowerCase();
          final isTargetRole = otherUserRole == 'trainer' || otherUserRole == 'barn_manager';
          return c.status == 'active' && isTargetRole;
        }).toList();

        if (filteredChats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const CommonText('No active chats', color: AppColors.textSecondary),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => controller.fetchConversations(),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filteredChats.length,
            separatorBuilder: (context, index) => Divider(height: 1, thickness: 1, color: AppColors.dividerColor, indent: 80, endIndent: 20),
            itemBuilder: (context, index) {
              final chat = filteredChats[index];
              return ListTile(
                onTap: () => Get.to(() => SingleChatView(
                  name: chat.otherUser?.name ?? 'Unknown',
                  image: chat.otherUser?.avatar ?? '',
                  conversationId: chat.conversationId,
                  otherId: chat.otherUser?.id,
                )),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: CommonImageView(
                  url: chat.otherUser?.avatar ?? '',
                  height: 56,
                  width: 56,
                  shape: BoxShape.circle,
                  isUserImage: true,
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText(chat.otherUser?.name ?? 'Unknown', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
                    CommonText(
                      chat.date != null ? _formatTime(chat.date!) : '',
                      fontSize: AppTextSizes.size12,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CommonText(
                          chat.lastMessage ?? 'No messages yet',
                          fontSize: AppTextSizes.size14,
                          color: AppColors.textSecondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unread > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(color: Color(0xFF13CA8B), shape: BoxShape.circle),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return DateFormat('MMM dd').format(date);
  }
}
