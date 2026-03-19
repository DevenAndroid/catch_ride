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
import '../../../constant/app_constants.dart';
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
            child: Obx(() {
              final currentUserId = Get.find<ProfileController>().id;
              final hasRequests = chatController.conversations.any(
                (c) =>
                    c.status == 'request-pending' &&
                    c.senderId != currentUserId,
              );

              return TextButton(
                onPressed: () => Get.to(() => const BarnManagerRequestsView()),
                child: Row(
                  children: [
                    if (hasRequests)
                      const Icon(Icons.circle, color: Colors.blue, size: 8),
                    const SizedBox(width: 6),
                    const CommonText(
                      'Requests',
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ],
                ),
              );
            }),
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
        onRefresh: () => chatController.fetchConversations(),
        child: Obx(() {
          if (chatController.isLoadingConversations.value &&
              chatController.conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final String currentUserId = Get.find<ProfileController>().id;
          final conversations = chatController.conversations.where((c) {
            // 1. Filter out self-conversations
            if (c.otherUser?.id == currentUserId) return false;

            // 2. Tab filtering
            bool belongsToTab = false;
            if (_selectedTab == 0) {
              belongsToTab = c.otherUser?.role == 'trainer' ||
                  c.otherUser?.role == 'barn_manager';
            } else {
              belongsToTab = c.otherUser?.role == 'service_provider' ||
                  c.otherUser?.role == 'vendor';
            }
            if (!belongsToTab) return false;

            // 3. Status filtering
            return c.status != 'request-pending' || c.senderId == currentUserId;
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
            separatorBuilder: (_, __) => const Padding(
              padding: EdgeInsets.only(left: 88),
              child: Divider(height: 1, color: Color(0xFFF2F4F7)),
            ),
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
    final profileController = Get.find<ProfileController>();
    final me = profileController.user.value;

    return InkWell(
      onTap: () => Get.to(
        () => BarnManagerSingleChatView(
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
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                        convo.otherUser?.avatar ?? AppConstants.dummyImageUrl,
                      ),
                      fit: BoxFit.cover,
                    ),
                    color: const Color(0xFFF2F4F7),
                  ),
                ),
                if (convo.unread > 0)
                  Positioned(
                    right: 0,
                    top: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF13CA8B,
                        ), // Custom green indicator
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
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
                    color: const Color(
                      0xFF535862,
                    ), // Matches screenshot dark-gray snippet
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
