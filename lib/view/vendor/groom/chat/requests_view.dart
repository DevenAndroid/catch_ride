import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/models/message_model.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestsView extends StatelessWidget {
  const RequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText('Requests', fontSize: AppTextSizes.size20, fontWeight: FontWeight.bold),
      ),
      body: Obx(() {
        final pendingRequests = controller.conversations.where((c) {
          final otherUserRole = c.otherUser?.role?.toLowerCase();
          final isTargetRole = otherUserRole == 'trainer' || otherUserRole == 'barn_manager';
          return c.status == 'request-pending' && isTargetRole;
        }).toList();

        if (controller.isLoadingConversations.value && pendingRequests.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (pendingRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mail_outline, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const CommonText('No pending requests', color: AppColors.textSecondary),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: pendingRequests.length,
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final request = pendingRequests[index];
            return _buildRequestCard(request, controller);
          },
        );
      }),
    );
  }

  Widget _buildRequestCard(ChatConversation convo, ChatController controller) {
    final other = convo.otherUser;
    final booking = convo.booking;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CommonImageView(
                  url: other?.avatar ?? '',
                  height: 52,
                  width: 52,
                  shape: BoxShape.circle,
                  isUserImage: true,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        '${other?.role ?? 'User'} : ${other?.name ?? 'Unknown'}',
                        fontSize: AppTextSizes.size16,
                        fontWeight: FontWeight.bold,
                      ),
                      if (booking?.location != null)
                        CommonText(
                          booking!.location!,
                          fontSize: AppTextSizes.size14,
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: CommonText(
                                  booking?.location ?? 'Location N/A',
                                  fontSize: AppTextSizes.size12,
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
                              const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 14),
                              const SizedBox(width: 6),
                              CommonText(
                                booking?.date ?? 'Date N/A',
                                fontSize: AppTextSizes.size12,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderLight)),
                      child: CommonText(
                        booking?.type ?? 'Service',
                        fontSize: AppTextSizes.size12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (booking?.notes != null && booking!.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  CommonText('Note - ${booking!.notes}', fontSize: AppTextSizes.size14, color: AppColors.textPrimary),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CommonButton(
                        text: 'Reject',
                        backgroundColor: Colors.white,
                        textColor: AppColors.textPrimary,
                        borderColor: AppColors.borderMedium,
                        onPressed: () => controller.declineRequest(convo.conversationId),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CommonButton(
                        text: 'Accept',
                        backgroundColor: AppColors.secondary,
                        onPressed: () => controller.acceptRequest(convo.conversationId),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
