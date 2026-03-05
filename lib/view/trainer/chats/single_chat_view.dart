import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/chat_bubble.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SingleChatView extends StatelessWidget {
  final String name;
  final String image;
  final String conversationId;
  final String? otherId;

  const SingleChatView({
    super.key,
    required this.name,
    required this.image,
    required this.conversationId,
    this.otherId,
  });

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.find<ChatController>();
    final TextEditingController textController = TextEditingController();

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
          onPressed: () {
            controller.activeConversationId.value = '';
            Get.back();
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: image.startsWith('http')
                  ? NetworkImage(image)
                  : const NetworkImage('https://via.placeholder.com/150'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    name,
                    fontSize: AppTextSizes.size16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    maxLines: 1,
                  ),
                  const CommonText(
                    'Professional Horse Trainer',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: Column(
        children: [
          // Banner for Pending/Declined status
          Obx(() {
            final convo = controller.conversations.firstWhereOrNull((c) => c.conversationId == conversationId);
            if (convo == null) return const SizedBox.shrink();

            if (convo.status == 'request-pending') {
              return _buildStatusBanner(
                'Waiting for your response',
                'Accept request to start chatting',
                Colors.orange.shade50,
                Colors.orange,
                actions: [
                  _buildBannerButton('Decline', () => controller.declineRequest(conversationId), isAction: false),
                  const SizedBox(width: 8),
                  _buildBannerButton('Accept', () => controller.acceptRequest(conversationId)),
                ],
              );
            } else if (convo.status == 'request-declined') {
              return _buildStatusBanner(
                'Conversation Restricted',
                'This request has been declined.',
                Colors.red.shade50,
                Colors.red,
              );
            } else if (convo.status == 'request-blocked') {
              return _buildStatusBanner(
                'Conversation Restricted',
                'This user has been blocked.',
                Colors.red.shade50,
                Colors.red,
              );
            }
            return const SizedBox.shrink();
          }),

          Expanded(
            child: Obx(() {
              if (controller.isLoadingMessages.value && controller.currentMessages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.currentMessages.isEmpty) {
                return const Center(
                  child: CommonText('No messages yet. Send a message to start!', color: AppColors.textSecondary),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                reverse: false, // We usually want newest at bottom, history is likely chronological
                itemCount: controller.currentMessages.length,
                itemBuilder: (context, index) {
                  final msg = controller.currentMessages[index];
                  final String currentUserId = Get.find<AuthController>().currentUser.value?.id ?? '';
                  
                  final bool isMe = msg.senderId == currentUserId || msg.senderName == 'You';
                  final bool isSystem = msg.senderId == 'system' || msg.status == 'request-declined' || msg.status == 'request-blocked';

                  if (isSystem) {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CommonText(
                          msg.content,
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return ChatBubble(
                    message: msg.content,
                    isMe: isMe,
                    time: DateFormat('hh:mm a').format(msg.timestamp),
                    isRead: msg.read,
                  );
                },
              );
            }),
          ),
          
          Obx(() {
            final convo = controller.conversations.firstWhereOrNull((c) => c.conversationId == conversationId);
            final bool canChat = convo?.status != 'request-declined' && 
                               convo?.status != 'request-pending' && 
                               convo?.status != 'request-blocked';
            
            if (!canChat) return const SizedBox.shrink();
            
            return _buildMessageInput(textController, controller);
          }),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(String title, String subtitle, Color bgColor, Color textColor, {List<Widget>? actions}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: bgColor,
      child: Column(
        children: [
          Icon(Icons.info_outline, color: textColor),
          const SizedBox(height: 8),
          CommonText(title, fontWeight: FontWeight.bold, color: textColor),
          CommonText(subtitle, fontSize: 12, color: textColor),
          if (actions != null) ...[
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: actions),
          ]
        ],
      ),
    );
  }

  Widget _buildBannerButton(String label, VoidCallback onTap, {bool isAction = true}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isAction ? Colors.green : Colors.grey.shade200,
        foregroundColor: isAction ? Colors.white : Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: CommonText(label, fontSize: 12, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildMessageInput(TextEditingController textController, ChatController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: 'Message',
                  hintStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  fillColor: const Color(0xFFF9FAFB),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                if (textController.text.isNotEmpty) {
                  controller.sendMessage(textController.text, receiverId: otherId);
                  textController.clear();
                }
              },
              child: Container(
                height: 48,
                width: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF101828),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
