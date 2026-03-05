import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/models/message_model.dart';
import 'package:catch_ride/view/trainer/chats/trainer_requests_view.dart';
import 'package:catch_ride/view/trainer/chats/single_chat_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/profile_controller.dart';
import '../../../services/socket_service.dart';

class TrainerChatsView extends StatelessWidget {
  const TrainerChatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.find<ChatController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const CommonText(
              'Inbox',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: 8),
            Obx(() {
              final isConnected = Get.find<SocketService>().isConnected.value;
              return Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isConnected ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Get.to(() => const TrainerRequestsView()),
            icon: Obx(() => Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: controller.conversations.any((c) => c.status == 'request-pending')
                        ? Colors.red
                        : Colors.blue,
                    shape: BoxShape.circle,
                  ),
                )),
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
      body: RefreshIndicator(
        onRefresh: () => controller.fetchConversations(),
        child: Obx(() {
          if (controller.isLoadingConversations.value && controller.conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentUserId = Get.find<ProfileController>().id;
          final activeConversations = controller.conversations
              .where((c) => c.status != 'request-pending' || c.senderId == currentUserId)
              .toList();

          if (activeConversations.isEmpty) {
            return const Center(
              child: CommonText('No active conversations', color: AppColors.textSecondary),
            );
          }

          return ListView.separated(
            itemCount: activeConversations.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: 80,
              endIndent: 16,
              color: AppColors.border,
            ),
            itemBuilder: (context, index) {
              final chat = activeConversations[index];
              return _buildChatItem(context, chat);
            },
          );
        }),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, ChatConversation chat) {
    final String name = chat.otherUser?.name ?? 'Unknown';
    final String message = chat.lastMessage ?? 'No messages yet';
    final String image = chat.otherUser?.avatar ?? AppConstants.dummyImageUrl;
    final String time = chat.date != null 
        ? DateFormat('hh:mm a').format(chat.date!) 
        : '';
    final bool isUnread = chat.unread > 0;

    return GestureDetector(
      onTap: () {
        Get.find<ChatController>().fetchMessages(chat.conversationId);
        Get.to(() => SingleChatView(
              name: name,
              image: image,
              conversationId: chat.conversationId,
              otherId: chat.otherUser?.id,
            ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: image.startsWith('http') 
              ? NetworkImage(image) 
              : const NetworkImage(AppConstants.dummyImageUrl),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CommonText(
                  name,
                  fontSize: AppTextSizes.size16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              CommonText(
                time,
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: CommonText(
              message,
              fontSize: 14,
              color: AppColors.textSecondary,
              maxLines: 1,
            ),
          ),
          trailing: isUnread
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
