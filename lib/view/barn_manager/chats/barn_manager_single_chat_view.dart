import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/chat_bubble.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../trainer/settings/trainer_profile_view.dart';
import '../../vendor/vendor_details_view.dart';

class BarnManagerSingleChatView extends StatefulWidget {
  final String name;
  final String image;
  final String conversationId;
  final String? otherId;

  const BarnManagerSingleChatView({
    super.key,
    required this.name,
    required this.image,
    required this.conversationId,
    this.otherId,
  });

  @override
  State<BarnManagerSingleChatView> createState() =>
      _BarnManagerSingleChatViewState();
}

class _BarnManagerSingleChatViewState extends State<BarnManagerSingleChatView> {
  final ChatController controller = Get.find<ChatController>();
  final TextEditingController textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch full conversation data every time we enter the view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMessages(widget.conversationId);
      controller.fetchConversations(); // Also refresh convo info for banners
      // Initial scroll to bottom after messages load
      Future.delayed(const Duration(milliseconds: 500), () {
        _scrollToBottom();
      });
    });

    // Pagination Listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !controller.isLoadingMore.value &&
          controller.hasMoreMessages.value) {
        controller.loadMoreMessages();
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    textController.dispose();
    _scrollController.dispose();
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
            color: Color(0xFF1F2937),
            size: 20,
          ),
          onPressed: () {
            controller.activeConversationId.value = '';
            Get.back();
          },
        ),
        title: GestureDetector(
          onTap: () {
            final convo = controller.conversations.firstWhereOrNull(
              (c) => c.conversationId == widget.conversationId,
            );
            final other = convo?.otherUser;
            if (other != null) {
              if (other.trainerId != null) {
                Get.to(() => TrainerProfileView(trainerId: other.trainerId!));
              } else if (other.vendorId != null) {
                Get.to(() => const VendorDetailsView(), arguments: {'vendorId': other.vendorId});
              }
            }
          },
          child: Row(
            children: [
              CommonImageView(
                url: widget.image,
                height: 40,
                width: 40,
                shape: BoxShape.circle,
                isUserImage: true,
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
                      color: const Color(0xFF101828),
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
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        final isLoading = controller.isUpdatingStatus.value;
        return Stack(
          children: [
            Column(
              children: [
                // Offline Banner
                Obx(() {
                  final isConnected =
                      Get.find<SocketService>().isConnected.value;
                  if (isConnected) return const SizedBox.shrink();

                  return Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: Colors.red.shade400,
                    child: const Row(
                      children: [
                        Icon(Icons.wifi_off_rounded,
                            color: Colors.white, size: 16),
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

                // Status banners
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
                            () =>
                                controller.declineRequest(widget.conversationId),
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
                  }
                  return const SizedBox.shrink();
                }),

                Expanded(
                  child: Obx(() {
                    if (controller.currentMessages.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                           _scrollController.jumpTo(0);
                        }
                      });
                    }
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
                      key: ValueKey(controller.activeConversationId.value),
                      controller: _scrollController,
                      reverse: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: controller.currentMessages.length + (controller.hasMoreMessages.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == controller.currentMessages.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        
                        final msgIndex = index;
                        if (msgIndex < 0 || msgIndex >= controller.currentMessages.length) {
                          return const SizedBox.shrink();
                        }

                        final msg = controller.currentMessages[msgIndex];
                        final String currentUserId =
                            Get.find<AuthController>()
                                    .currentUser
                                    .value
                                    ?.id ??
                                '';

                        final bool isMe = msg.senderId == currentUserId ||
                            msg.senderName == 'You';

                        return ChatBubble(
                          message: msg.content,
                          isMe: isMe,
                          time: isMe &&
                                  index == controller.currentMessages.length - 1
                              ? 'Just now'
                              : '',
                          isRead: msg.read &&
                              index == controller.currentMessages.length - 1,
                        );
                      },
                    );
                  }),
                ),

                Obx(() {
                  final convo = controller.conversations.firstWhereOrNull(
                    (c) => c.conversationId == widget.conversationId,
                  );
                  final bool canChat = convo?.status != 'request-declined' &&
                      convo?.status != 'request-pending' &&
                      convo?.status != 'request-blocked';

                  if (!canChat) return const SizedBox.shrink();

                  return _buildMessageInput(textController, controller);
                }),
              ],
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      }),
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
          Icon(Icons.info_outline, color: textColor, size: 20),
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
        backgroundColor: isAction
            ? const Color(0xFF00083B)
            : const Color(0xFFF2F4F7),
        foregroundColor: isAction ? Colors.white : const Color(0xFF344054),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAECF0))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD0D5DD)),
                ),
                child: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'Message',
                    hintStyle: TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 16,
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
                  color: Color(0xFF00083B),
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
