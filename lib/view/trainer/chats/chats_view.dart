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
import '../../../models/user_model.dart';

class TrainerChatsView extends StatefulWidget {
  const TrainerChatsView({super.key});

  @override
  State<TrainerChatsView> createState() => _TrainerChatsViewState();
}

class _TrainerChatsViewState extends State<TrainerChatsView> {
  final ChatController chatController = Get.find<ChatController>();
  final ProfileController profileController = Get.find<ProfileController>();
  int _selectedTab = 0; // 0 for Trainers, 1 for Service Providers

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 4),
          child: CommonText(
            'Inbox',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: () => Get.to(() => const TrainerRequestsView()),
              child: const Row(
                children: [
                  Icon(Icons.circle, color: Colors.blue, size: 8),
                  SizedBox(width: 6),
                  CommonText(
                    'Requests',
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              const Divider(height: 1, color: Color(0xFFEAECF0)),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: const Color(0xFFEAECF0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildTab(0, 'Trainers')),
                      Expanded(child: _buildTab(1, 'Service Providers')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await chatController.fetchConversations();
          await profileController.fetchProfile();
        },
        child: Obx(() {
          if (chatController.isLoadingConversations.value &&
              chatController.conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final String currentUserId = profileController.id;
          final me = profileController.user.value;
          debugPrint('DEBUG: current role: ${me?.role}, linkedBM: ${me?.linkedBarnManager != null}, BM userId: ${me?.linkedBarnManager?.userId}');
          
          final conversations = chatController.conversations.where((c) {
            if (c.otherUser?.id == currentUserId) return false;

            bool belongsToTab = false;
            if (_selectedTab == 0) {
              belongsToTab = c.otherUser?.role == 'trainer' ||
                  c.otherUser?.role == 'barn_manager';
            } else {
              belongsToTab = c.otherUser?.role == 'service_provider' ||
                  c.otherUser?.role == 'vendor';
            }
            if (!belongsToTab) return false;

            return c.status != 'request-pending';
          }).toList();

          if (conversations.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 64,
                        color: AppColors.textSecondary.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      CommonText(
                        'No ${_selectedTab == 0 ? 'trainer' : 'service provider'} chats',
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: conversations.length,
            padding: EdgeInsets.zero,
            separatorBuilder: (_, index) {
              // If it's the divider after the BM row, we might want a different padding or color
              return const Padding(
                padding: EdgeInsets.only(left: 88),
                child: Divider(height: 1, color: Color(0xFFF2F4F7)),
              );
            },
            itemBuilder: (context, index) {
              final convo = conversations[index];
              return _buildChatItem(convo);
            },
          );
        }),
      ),
    );
  }



  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B4444) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: CommonText(
          label,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : const Color(0xFF667085),
        ),
      ),
    );
  }

  Widget _buildChatItem(ChatConversation convo) {
    final me = profileController.user.value;

    return InkWell(
      onTap: () => Get.to(
        () => SingleChatView(
          name: convo.otherUser?.name ?? 'Unknown',
          image: convo.otherUser?.avatar ?? '',
          conversationId: convo.conversationId,
          otherId: convo.otherUser?.id,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CommonImageView(
                  url: convo.otherUser?.avatar,
                  width: 56,
                  height: 56,
                  shape: BoxShape.circle,
                  isUserImage: true,
                ),

                if (convo.unread > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF04438), // Red for notifications
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Center(
                        child: CommonText(
                          convo.unread > 99 ? '99+' : convo.unread.toString(),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF101828),
                              fontFamily: 'Outfit',
                            ),
                            children: [
                              TextSpan(
                                text: convo.otherUser?.name ?? 'Unknown',
                              ),
                              if (convo.label != null)
                                TextSpan(
                                  text: ' ${convo.label}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2E90FA),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CommonText(
                        _formatTime(convo.date ?? DateTime.now()),
                        fontSize: 13,
                        color: const Color(0xFF667085),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  CommonText(
                    convo.lastMessage ?? 'No messages yet',
                    fontSize: 15,
                    color: const Color(0xFF535862),
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

    if (difference.inMinutes < 1) return 'now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} mins ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays < 7) return '${difference.inDays} days ago';

    return DateFormat('dd MMM').format(date);
  }
}
