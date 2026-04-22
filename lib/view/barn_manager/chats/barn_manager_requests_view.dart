import 'package:catch_ride/controllers/booking_controller.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/models/booking_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../constant/app_colors.dart';
import '../../../controllers/profile_controller.dart';
import '../../../widgets/common_image_view.dart';
import '../../../widgets/common_text.dart';
import 'barn_manager_single_chat_view.dart';

class BarnManagerRequestsView extends StatefulWidget {
  const BarnManagerRequestsView({super.key});

  @override
  State<BarnManagerRequestsView> createState() => _BarnManagerRequestsViewState();
}

class _BarnManagerRequestsViewState extends State<BarnManagerRequestsView> {
  final ChatController controller = Get.find<ChatController>();
  final BookingController bookingController = Get.isRegistered<BookingController>() 
      ? Get.find<BookingController>() 
      : Get.put(BookingController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<BookingController>().fetchBookings(type: 'received');
      Get.find<ChatController>().fetchConversations();
    });
  }

  @override
  Widget build(BuildContext context) {


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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: Obx(() {
        final pendingBookings = bookingController.receivedBookings
            .where((b) => b.status == 'pending' || b.status == 'requested')
            .toList();

        return Stack(
          children: [
            if (bookingController.isLoading.value && pendingBookings.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (pendingBookings.isEmpty)
              RefreshIndicator(
                onRefresh: () async => bookingController.fetchBookings(type: 'received'),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: const Center(
                        child: CommonText(
                          'No pending requests',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              RefreshIndicator(
                onRefresh: () async => bookingController.fetchBookings(type: 'received'),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: pendingBookings.length,
                  itemBuilder: (context, index) {
                    return RequestCard(booking: pendingBookings[index]);
                  },
                ),
              ),
            if (controller.isUpdatingStatus.value)
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
}

class RequestCard extends StatelessWidget {
  final BookingModel booking;
  const RequestCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final ChatController chatController = Get.find<ChatController>();
    final String name = booking.clientName ?? 'Unknown';
    final String role = booking.acceptedByRole ?? 'User';
    final String? avatar = booking.clientImage;

    return GestureDetector(
      onTap: () {
         final String cid = chatController.getNormalizedConversationId(
              booking.clientId ?? '', 
              Get.find<ProfileController>().id
            );
        Get.to(
          () => BarnManagerSingleChatView(
            name: name,
            image: avatar ?? '',
            conversationId: cid,
            otherId: booking.clientId,
          ),
        );
      },
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
                  isUserImage: true,
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
                  color: AppColors.border.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CommonImageView(
                        url: booking.horseImage,
                        height: 80,
                        width: 80,
                        radius: 8,
                        fit: BoxFit.cover,
                      ),
                      if (booking.type.isNotEmpty)
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
                              booking.type,
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
                              booking.horseName ?? "Booking Request",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ],
                        ),
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
                                booking.location ?? 'N/A',
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
                              booking.date,
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
                  booking.notes ?? 'No message provided',
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
                      final bController = Get.find<BookingController>();
                      bool success = await bController.updateBookingStatus(
                        booking.id!, 
                        'rejected'
                      ) != null;
                      
                      if (success) {
                        chatController.fetchConversations();
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
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final bController = Get.find<BookingController>();
                      final result = await bController.updateBookingStatus(
                        booking.id!, 
                        'confirmed'
                      );
                      
                      if (result != null && result is Map) {
                        final String? generalId = result['conversationId'];
                        
                        // Refresh chat list to reflect acceptance
                        chatController.fetchConversations();
                        
                        // Redirect directly to the chat view
                        Get.to(() => BarnManagerSingleChatView(
                              name: name,
                              image: avatar ?? '',
                              conversationId: generalId ?? '', 
                              otherId: booking.clientId,
                            ));
                      } else {
                        Get.snackbar('Error', 'Failed to accept booking');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xff12937E),
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
    ));
  }
}
