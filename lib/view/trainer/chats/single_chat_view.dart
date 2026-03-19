import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/chat_bubble.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/profile_controller.dart';

class SingleChatView extends StatefulWidget {
  final String name;
  final String image;
  final String conversationId;
  final String? otherId;
  final bool readOnly;

  const SingleChatView({
    super.key,
    required this.name,
    required this.image,
    required this.conversationId,
    this.otherId,
    this.readOnly = false,
  });

  @override
  State<SingleChatView> createState() => _SingleChatViewState();
}

class _SingleChatViewState extends State<SingleChatView> {
  final ChatController controller = Get.find<ChatController>();
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch full conversation data every time we enter the view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMessages(widget.conversationId);
      if (!widget.readOnly) {
        controller.fetchConversations(); // Also refresh convo info for banners
      }
    });
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            controller.clearActiveConversation();
            Get.back();
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: widget.image.startsWith('http')
                  ? NetworkImage(widget.image)
                  : const NetworkImage('https://via.placeholder.com/150'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    widget.name,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    maxLines: 1,
                  ),
                  Obx(() {
                    final convo = controller.conversations.firstWhereOrNull(
                      (c) => c.conversationId == widget.conversationId,
                    );
                    final other = convo?.otherUser;
                    final me = Get.find<ProfileController>().user.value;

                    if (other != null && me != null) {
                      // Case 1: I am BM, other is my Boss
                      if (me.role == 'barn_manager' &&
                          other.id == me.trainerProfileId) {
                        return const CommonText(
                          '(Associated Trainer)',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E90FA),
                        );
                      }
                      // Case 2: I am Trainer, other is my BM
                      if (me.role == 'trainer' &&
                          other.role == 'barn_manager' &&
                          other.trainerId == me.trainerProfileId) {
                        return const CommonText(
                          '(Associated Barn Manager)',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E90FA),
                        );
                      }
                    }

                    if (widget.readOnly) {
                      return const CommonText(
                        'Read-only View',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.redAccent,
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Offline Banner
          Obx(() {
            final isConnected = Get.find<SocketService>().isConnected.value;
            if (isConnected) return const SizedBox.shrink();

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.red.shade400,
              child: const Row(
                children: [
                  Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: CommonText(
                      'Socket not connected. Some messages might not be real-time.',
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Banner for Pending/Declined status
          Obx(() {
            final convo = controller.conversations.firstWhereOrNull(
              (c) => c.conversationId == widget.conversationId,
            );
            if (convo == null) return const SizedBox.shrink();

            final currentUserId = Get.find<ProfileController>().id;
            final isSender = convo.senderId == currentUserId;

            if (convo.status == 'request-pending') {
              if (isSender) {
                return _buildStatusBanner(
                  'Request Pending',
                  'Waiting for professional to accept your request',
                  Colors.blue.shade50,
                  Colors.blue,
                );
              } else {
                return _buildStatusBanner(
                  'Waiting for your response',
                  'Accept request to start chatting',
                  Colors.orange.shade50,
                  Colors.orange,
                  actions: [
                    _buildBannerButton(
                      'Decline',
                      () => controller.declineRequest(widget.conversationId),
                      isAction: false,
                    ),
                    const SizedBox(width: 8),
                    _buildBannerButton(
                      'Accept',
                      () => controller.acceptRequest(widget.conversationId),
                    ),
                  ],
                );
              }
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
              if (controller.isLoadingMessages.value &&
                  controller.currentMessages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.currentMessages.isEmpty) {
                return const Center(
                  child: CommonText(
                    'No messages yet. Send a message to start!',
                    color: AppColors.textSecondary,
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: controller.currentMessages.length,
                itemBuilder: (context, index) {
                  final msgIndex = index;
                  if (msgIndex >= controller.currentMessages.length)
                    return const SizedBox.shrink();

                  final msg = controller.currentMessages[msgIndex];
                  final String currentUserId =
                      Get.find<AuthController>().currentUser.value?.id ?? '';

                  final bool isMe =
                      msg.senderId == currentUserId || msg.senderName == 'You';
                  final bool isSystem =
                      msg.senderId == 'system' ||
                      msg.status == 'request-declined' ||
                      msg.status == 'request-blocked';

                  if (isSystem) {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
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
                    time: '',
                    isRead: msg.read,
                  );
                },
              );
            }),
          ),

          Obx(() {
            final convo = controller.conversations.firstWhereOrNull(
              (c) => c.conversationId == widget.conversationId,
            );
            final bool canChat =
                convo?.status != 'request-declined' &&
                convo?.status != 'request-pending' &&
                convo?.status != 'request-blocked';

            if (!canChat || widget.readOnly) return const SizedBox.shrink();

            return _buildMessageInput(textController, controller);
          }),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(
    String title,
    String subtitle,
    Color bgColor,
    Color textColor, {
    List<Widget>? actions,
  }) {
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
          ],
        ],
      ),
    );
  }

  Widget _buildBannerButton(
    String label,
    VoidCallback onTap, {
    bool isAction = true,
  }) {
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

  Widget _buildMessageInput(
    TextEditingController textController,
    ChatController controller,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: const BoxDecoration(color: Colors.white),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'Message',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                    suffixIcon: Icon(
                      Icons.attach_file_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                if (textController.text.isNotEmpty) {
                  controller.sendMessage(
                    textController.text,
                    receiverId: widget.otherId,
                  );
                  textController.clear();
                }
              },
              child: Container(
                height: 48,
                width: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primary, // Navy blue from design
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
