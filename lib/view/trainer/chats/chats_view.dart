import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/models/message_model.dart';
import 'package:catch_ride/view/trainer/chats/trainer_requests_view.dart';
import 'package:catch_ride/view/trainer/chats/single_chat_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/profile_controller.dart';

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
        centerTitle: false,
        title: const CommonText(
          'Inbox',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.to(() => const TrainerRequestsView()),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E90FA), // Blue dot
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const CommonText(
                  'Requests',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E90FA),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchConversations(),
        child: Obx(() {
          if (controller.isLoadingConversations.value && controller.conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentUserId = Get.find<ProfileController>().id;
          List<ChatConversation> activeConversations = controller.conversations
              .where((c) => c.status != 'request-pending' || c.senderId == currentUserId)
              .toList();

          // INJECT DUMMY DATA FOR UI VERIFICATION
          if (activeConversations.isEmpty) {
            activeConversations = [
              ChatConversation(
                id: '1',
                conversationId: 'c1',
                lastMessage: 'Thanks so much, happy with that.',
                date: DateTime.now().subtract(const Duration(minutes: 2)),
                unread: 1,
                otherUser: ChatOtherUser(
                  id: 'u1',
                  name: 'Lana Steiner',
                  avatar: 'https://i.pravatar.cc/150?u=lana',
                ),
              ),
              ChatConversation(
                id: '2',
                conversationId: 'c2',
                lastMessage: 'Got you a coffee',
                date: DateTime.now().subtract(const Duration(minutes: 2)),
                unread: 0,
                otherUser: ChatOtherUser(
                  id: 'u2',
                  name: 'Demi Wilkinson',
                  avatar: 'https://i.pravatar.cc/150?u=demi',
                ),
              ),
              ChatConversation(
                id: '3',
                conversationId: 'c3',
                lastMessage: 'Great to see you again!',
                date: DateTime.now().subtract(const Duration(hours: 3)),
                unread: 0,
                otherUser: ChatOtherUser(
                  id: 'u3',
                  name: 'Candice Wu',
                  avatar: 'https://i.pravatar.cc/150?u=candice',
                ),
              ),
              ChatConversation(
                id: '4',
                conversationId: 'c4',
                lastMessage: 'We should ask Oli about this...',
                date: DateTime.now().subtract(const Duration(hours: 6)),
                unread: 0,
                otherUser: ChatOtherUser(
                  id: 'u4',
                  name: 'Natali Craig',
                  avatar: 'https://i.pravatar.cc/150?u=natali',
                ),
              ),
              ChatConversation(
                id: '5',
                conversationId: 'c5',
                lastMessage: 'Okay, see you then.',
                date: DateTime.now().subtract(const Duration(hours: 12)),
                unread: 0,
                otherUser: ChatOtherUser(
                  id: 'u5',
                  name: 'Drew Cano',
                  avatar: 'https://i.pravatar.cc/150?u=drew',
                ),
              ),
              ChatConversation(
                id: '6',
                conversationId: 'c6',
                lastMessage: 'Okay, see you then.',
                date: DateTime.now().subtract(const Duration(hours: 12)),
                unread: 0,
                otherUser: ChatOtherUser(
                  id: '6',
                  name: 'Drew Cano',
                  avatar: 'https://i.pravatar.cc/150?u=drew',
                ),
              ),
              ChatConversation(
                id: '7',
                conversationId: 'c7',
                lastMessage: 'Okay, see you then.',
                date: DateTime.now().subtract(const Duration(hours: 12)),
                unread: 0,
                otherUser: ChatOtherUser(
                  id: '7',
                  name: 'Drew Cano',
                  avatar: 'https://i.pravatar.cc/150?u=drew',
                ),
              ),
            ];
          }

          return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: activeConversations.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFF2F4F7),
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
    
    // Better time formatting
    String time = '';
    if (chat.date != null) {
      final diff = DateTime.now().difference(chat.date!);
      if (diff.inMinutes < 60) {
        time = '${diff.inMinutes} mins ago';
      } else if (diff.inHours < 24) {
        time = '${diff.inHours} hours ago';
      } else {
        time = DateFormat('MMM d').format(chat.date!);
      }
    }

    final bool isUnread = chat.unread > 0;

    return InkWell(
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonImageView(
              url: image,
              height: 52,
              width: 52,
              shape: BoxShape.circle,
              fallbackIcon: Icons.person,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: CommonText(
                                name,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            CommonText(
                              time,
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF17B26A), // Green dot
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  CommonText(
                    message,
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
