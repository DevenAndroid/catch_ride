import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'barn_manager_single_chat_view.dart';
import 'package:catch_ride/controllers/profile_controller.dart';

class BarnManagerRequestsView extends StatelessWidget {
  const BarnManagerRequestsView({super.key});

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
            color: Color(0xFF1F2937),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Requests',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF101828),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
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
            return BarnManagerRequestCard(request: requests[index]);
          },
        );
      }),
    );
  }
}

class BarnManagerRequestCard extends StatelessWidget {
  final ChatConversation request;
  const BarnManagerRequestCard({super.key, required this.request});

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
        color: const Color(
          0xFFF9F5F0,
        ), // Lighter version of the cream background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5D5C5).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - User Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CommonImageView(
                  url: avatar,
                  height: 48,
                  width: 48,
                  shape: BoxShape.circle,
                  fallbackIcon: Icons.person,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        "Requester : $name",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF101828),
                      ),
                      const SizedBox(height: 2),
                      CommonText(
                        role,
                        fontSize: 14,
                        color: const Color(0xFF667085),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Horse Card Content
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CommonImageView(
                        url:
                            request.booking?.horseImage ??
                            AppConstants.dummyImageUrl,
                        height: 90,
                        width: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CommonText(
                                request.booking?.horseName ?? "Booking Request",
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF101828),
                              ),
                              if (request.booking?.type != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF2F4F7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: CommonText(
                                    request.booking!.type,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF475467),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: Color(0xFF98A2B3),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: CommonText(
                                  request.booking?.location ?? 'N/A',
                                  fontSize: 14,
                                  color: const Color(0xFF667085),
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
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: Color(0xFF98A2B3),
                              ),
                              const SizedBox(width: 6),
                              CommonText(
                                request.booking?.date ?? 'N/A',
                                fontSize: 14,
                                color: const Color(0xFF667085),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Message/Note Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: CommonText(
              "Note - ${request.lastMessage ?? request.booking?.notes ?? "No notes provided"}",
              fontSize: 14,
              color: const Color(0xFF344054),
              height: 1.5,
            ),
          ),

          // Buttons Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        controller.acceptRequest(request.conversationId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF8B4541,
                      ), // Brownish red from image
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const CommonText(
                      'Accept',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        controller.declineRequest(request.conversationId),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFD0D5DD)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const CommonText(
                      'Reject',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF344054),
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
