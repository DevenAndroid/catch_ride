import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/view/trainer/chats/single_chat_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/profile_controller.dart';

class TrainerRequestsView extends StatelessWidget {
  const TrainerRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.find<ChatController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
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
          fontSize: AppTextSizes.size18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border.withOpacity(0.5), height: 1.0),
        ),
      ),
      body: Obx(() {
        final currentUserId = Get.find<ProfileController>().id;
        final requests = controller.conversations
            .where((c) => c.status == 'request-pending')
            .toList();

        if (requests.isEmpty) {
          return const Center(
            child: CommonText('No pending requests', color: AppColors.textSecondary),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
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
    final String avatar = request.otherUser?.avatar ?? AppConstants.dummyImageUrl;

    return GestureDetector(
      onTap: () {
        controller.fetchMessages(request.conversationId);
        Get.to(() => SingleChatView(
              name: name,
              image: avatar,
              conversationId: request.conversationId,
              otherId: request.otherUser?.id,
            ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header - Light Blue Background
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFFE5F1FF),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: avatar.startsWith('http') 
                      ? NetworkImage(avatar) 
                      : const NetworkImage(AppConstants.dummyImageUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          name,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        CommonText(
                          role,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Last Message Snippet
            Padding(
              padding: const EdgeInsets.all(16),
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
                    request.lastMessage ?? 'No message provided',
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
    
            // Actions or Status
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: request.senderId == Get.find<ProfileController>().id 
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: CommonText(
                        'Awaiting response from professional',
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final success = await controller.declineRequest(request.conversationId);
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
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const CommonText(
                            'Reject',
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final success = await controller.acceptRequest(request.conversationId);
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF17B26A),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const CommonText(
                            'Accept',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
