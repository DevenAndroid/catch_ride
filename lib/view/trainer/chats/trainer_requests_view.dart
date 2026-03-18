import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/controllers/profile_controller.dart';

class TrainerRequestsView extends StatelessWidget {
  const TrainerRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.find<ChatController>();

    return Scaffold(
      backgroundColor: AppColors.background,
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
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Requests',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      body: Obx(() {
        final currentUserId = Get.find<ProfileController>().id;
        final requests = controller.conversations
            .where(
              (c) =>
                  c.status == 'request-pending' && c.senderId != currentUserId,
            )
            .toList();

        if (requests.isEmpty) {
          return const Center(
            child: CommonText(
              'No pending requests',
              color: AppColors.textSecondary,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            return RequestCard(request: requests[index]);
          },
        );
      }),
    );
  }
}

class RequestCard extends StatelessWidget {
  final ChatConversation request;
  const RequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.find<ChatController>();
    final String name = request.otherUser?.name ?? 'Unknown';
    final String role = request.otherUser?.role ?? 'User';
    final String avatar =
        request.otherUser?.avatar ?? AppConstants.dummyImageUrl;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Light Cream Background
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
                  fallbackIcon: Icons.person,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CommonText(
                            "Requester : $name",
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ],
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

          // Horse Details Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CommonImageView(
                        url:
                            request.booking?.horseImage ??
                            AppConstants.dummyImageUrl,
                        height: 80,
                        width: 80,
                        radius: 8,
                        fit: BoxFit.cover,
                        fallbackIcon: Icons.image,
                      ),
                      if (request.booking?.type != null)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: CommonText(
                              request.booking!.type,
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
                            CommonText(
                              request.booking?.horseName ?? "Booking Request",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            if (request.booking?.type != null)
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
                                  request.booking!.type,
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
                                request.booking?.location ?? 'N/A',
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
                            CommonText(
                              request.booking?.date ?? 'N/A',
                              fontSize: 13,
                              color: AppColors.textSecondary,
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
                  request.booking?.notes ??
                      request.lastMessage ??
                      'No message provided',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  maxLines: 5,
                ),
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final success = await controller.declineRequest(
                        request.conversationId,
                      );
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: CommonText(
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
                    onTap: () async {
                      final success = await controller.acceptRequest(
                        request.conversationId,
                      );
                      if (success) {
                        Get.snackbar(
                          'Success',
                          'Request accepted',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF17B26A),
                          colorText: Colors.white,
                          barBlur: 0,
                          margin: const EdgeInsets.all(16),
                        );
                        // Maybe navigate to the chat or just stay here while it's removed from list
                      } else {
                        Get.snackbar('Error', 'Failed to accept request');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors
                            .secondary, // Updated to AppColors.secondary
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: CommonText(
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
    );
  }
}
