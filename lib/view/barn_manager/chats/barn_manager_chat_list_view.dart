import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/models/message_model.dart';
import 'package:catch_ride/view/barn_manager/chats/barn_manager_single_chat_view.dart';
import 'package:catch_ride/view/barn_manager/chats/barn_manager_requests_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/profile_controller.dart';

class BarnManagerInboxView extends StatefulWidget {
  const BarnManagerInboxView({super.key});

  @override
  State<BarnManagerInboxView> createState() => _BarnManagerInboxViewState();
}

class _BarnManagerInboxViewState extends State<BarnManagerInboxView> {
  final ChatController chatController = Get.put(ChatController());
  int _selectedTab = 0; // 0 for Trainers, 1 for Service Providers

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const CommonText(
          'Inbox',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Obx(() {
              final currentUserId = Get.find<ProfileController>().id;
              final hasRequests = chatController.conversations.any((c) => c.status == 'request-pending' && c.senderId != currentUserId);
              final color = hasRequests ? const Color(0xFFF04438) : Colors.blue;

              return TextButton(
                onPressed: () => Get.to(() => const BarnManagerRequestsView()),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    CommonText(
                      'Requests',
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Column(
            children: [
              Container(color: AppColors.border, height: 1.0),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildTab(0, 'Trainers')),
                      Expanded(child: _buildTab(1, 'Service Providers')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (chatController.isLoadingConversations.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final conversations = chatController.conversations
            .where((c) => c.status != 'request-pending')
            .toList();

        if (conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
                const SizedBox(height: 16),
                const CommonText(
                  'No messages yet',
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: conversations.length,
          padding: const EdgeInsets.only(top: 8, bottom: 20),
          separatorBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(left: 80),
            child: Container(color: const Color(0xFFF2F4F7), height: 1.0),
          ),
          itemBuilder: (context, index) {
            final convo = conversations[index];
            return _buildChatItem(convo, index == 0);
          },
        );
      }),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: CommonText(
          label,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? const Color(0xFF101828) : const Color(0xFF667085),
        ),
      ),
    );
  }

  Widget _buildChatItem(ChatConversation convo, bool isAssociatedTrainer) {
    return InkWell(
      onTap: () => Get.to(() => BarnManagerSingleChatView(
            name: convo.otherUser?.name ?? 'Unknown',
            image: convo.otherUser?.avatar ?? '',
            conversationId: convo.conversationId,
            otherId: convo.otherUser?.id,
          )),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(convo.otherUser?.avatar ?? ''),
                  backgroundColor: AppColors.inputBackground,
                ),
                if (convo.unread > 0)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF12B76A), // Green dot
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: convo.otherUser?.name ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF101828),
                              fontFamily: 'Inter',
                            ),
                            children: [
                              if (isAssociatedTrainer)
                                const TextSpan(
                                  text: ' (Associated Trainer)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      CommonText(
                        _formatTime(convo.date ?? DateTime.now()),
                        fontSize: 12,
                        color: const Color(0xFF667085),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  CommonText(
                    convo.lastMessage ?? '',
                    fontSize: 14,
                    color: const Color(0xFF667085),
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

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }
}
