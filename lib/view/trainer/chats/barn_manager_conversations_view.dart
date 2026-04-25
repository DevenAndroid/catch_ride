import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/models/message_model.dart';
import 'package:catch_ride/view/trainer/chats/single_chat_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:catch_ride/widgets/common_image_view.dart';
import '../../../controllers/profile_controller.dart';

class BarnManagerConversationsListView extends StatefulWidget {
  final String barnManagerUserId;
  final String barnManagerName;

  const BarnManagerConversationsListView({
    super.key,
    required this.barnManagerUserId,
    required this.barnManagerName,
  });

  @override
  State<BarnManagerConversationsListView> createState() => _BarnManagerConversationsListViewState();
}

class _BarnManagerConversationsListViewState extends State<BarnManagerConversationsListView> {
  final ChatController chatController = Get.find<ChatController>();
  final RxList<ChatConversation> bmConversations = <ChatConversation>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _fetchBMConversations();
  }

  Future<void> _fetchBMConversations() async {
    try {
      isLoading.value = true;
      // We use a custom fetch since the main chatController.conversations is for the current user
      final results = await chatController.fetchConversationsForUser(widget.barnManagerUserId);
      bmConversations.assignAll(results);
    } catch (e) {
      debugPrint('Error fetching BM conversations: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              '${widget.barnManagerName}\'s Chats',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            const CommonText(
              'Read-only View',
              fontSize: 12,
              color: Colors.grey,
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchBMConversations,
        child: Obx(() {
          if (isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bmConversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 64,
                    color: AppColors.textSecondary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  const CommonText(
                    'No conversations found',
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: bmConversations.length,
            separatorBuilder: (_, __) => const Padding(
              padding: EdgeInsets.only(left: 88),
              child: Divider(height: 1, color: Color(0xFFF2F4F7)),
            ),
            itemBuilder: (context, index) {
              final convo = bmConversations[index];
              return _buildChatItem(convo);
            },
          );
        }),
      ),
    );
  }

  Widget _buildChatItem(ChatConversation convo) {
    return InkWell(
      onTap: () => Get.to(
        () => SingleChatView(
          name: convo.otherUser?.name ?? 'Unknown',
          image: convo.otherUser?.avatar ?? '',
          conversationId: convo.conversationId,
          otherId: convo.otherUser?.id,
          readOnly: true, // IMPORTANT: Trainer can only view
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CommonImageView(
              width: 56,
              height: 56,
              shape: BoxShape.circle,
              url: convo.otherUser?.avatar?.isNotEmpty == true
                  ? convo.otherUser!.avatar!
                  : null,
              isUserImage: true,
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
                        child: CommonText(
                          convo.otherUser?.name ?? 'Unknown',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF101828),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CommonText(
                        convo.date != null ? _formatTime(convo.date!) : 'now',
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
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    return DateFormat('dd MMM').format(date);
  }
}
