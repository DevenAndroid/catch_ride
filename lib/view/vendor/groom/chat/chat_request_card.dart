import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/view/trainer/chats/single_chat_view.dart';
import 'package:catch_ride/models/message_model.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatRequestCard extends StatefulWidget {
  final ChatConversation request;
  const ChatRequestCard({super.key, required this.request});

  @override
  State<ChatRequestCard> createState() => _ChatRequestCardState();
}

class _ChatRequestCardState extends State<ChatRequestCard> {
  bool _isAccepting = false;
  bool _isRejecting = false;

  bool get _isBusy => _isAccepting || _isRejecting;

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.find<ChatController>();
    final String name = (widget.request.otherUser?.name != null && widget.request.otherUser!.name!.isNotEmpty && widget.request.otherUser!.name != 'Unknown')
        ? widget.request.otherUser!.name!
        : (widget.request.booking?.trainerName ?? widget.request.booking?.clientName ?? 'Unknown');
    final String role = widget.request.otherUser?.role ?? 'User';
    final String? avatar = widget.request.otherUser?.avatar ?? widget.request.booking?.trainerImage ?? widget.request.booking?.clientImage;

    return GestureDetector(
      onTap: () => Get.to(
        () => SingleChatView(
          name: name,
          image: avatar ?? '',
          conversationId: widget.request.conversationId,
          otherId: widget.request.otherUser?.id,
        ),
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF5EFE7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                CommonImageView(
                  url: avatar,
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
                        "Requester : $name",
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      CommonText(
                        role,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CommonImageView(
                        url: avatar,
                        height: 80,
                        width: 80,
                        radius: 8,
                        fit: BoxFit.cover,
                        isUserImage: true,
                      ),
                      if (widget.request.booking?.type != null)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: CommonText(
                              widget.request.booking!.type,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
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
                              child: CommonText(
                                widget.request.booking?.horseName ?? "Booking Request",
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.request.booking?.type != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F4F7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: CommonText(
                                  widget.request.booking!.type,
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: CommonText(
                                widget.request.booking?.location ?? 'N/A',
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: CommonText(
                                widget.request.booking?.date ?? 'N/A',
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CommonText(
                  'Message Request:',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 4),
                CommonText(
                  widget.request.booking?.notes ??
                      widget.request.lastMessage ??
                      'No message provided',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  maxLines: 5,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _isBusy
                        ? null
                        : () async {
                              setState(() => _isRejecting = true);
                              final success = await controller.declineRequest(
                                widget.request.conversationId,
                                bookingId: widget.request.booking?.id,
                              );
                              if (mounted) setState(() => _isRejecting = false);
                              
                              if (success) {
                                Get.snackbar(
                                  'Success',
                                  'Request declined',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.black87,
                                  colorText: Colors.white,
                                  barBlur: 0,
                                  margin: const EdgeInsets.all(16),
                                );
                              } else {
                                Get.snackbar(
                                  'Error',
                                  'Failed to decline request',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.redAccent,
                                  colorText: Colors.white,
                                  barBlur: 0,
                                  margin: const EdgeInsets.all(16),
                                );
                              }
                            },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _isRejecting ? Colors.grey.shade100 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: _isRejecting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textPrimary,
                            ),
                          )
                        : const CommonText(
                            'Reject',
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                    ),
                  ),
                ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _isBusy
                        ? null
                        : () async {
                              setState(() => _isAccepting = true);
                              final String? generalId = await controller.acceptRequest(
                                widget.request.conversationId,
                                bookingId: widget.request.booking?.id,
                              );
                              if (mounted) setState(() => _isAccepting = false);

                              if (generalId != null) {
                                Get.snackbar(
                                  'Success',
                                  'Request accepted',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: const Color(0xFF17B26A),
                                  colorText: Colors.white,
                                  barBlur: 0,
                                  margin: const EdgeInsets.all(16),
                                );

                                // Redirect to the same chat view (unlocked)
                                Get.to(() => SingleChatView(
                                      name: name,
                                      image: avatar ?? '',
                                      conversationId: generalId,
                                      otherId: widget.request.otherUser?.id,
                                    ));
                              } else {
                                Get.snackbar('Error', 'Failed to accept request');
                              }
                            },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _isAccepting ? const Color(0xFF0e7a68) : const Color(0xff12937E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: _isAccepting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const CommonText(
                              'Accept',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
