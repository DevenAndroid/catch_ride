import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/view/trainer/chats/single_chat_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/controllers/booking_controller.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/models/booking_model.dart';
import 'package:catch_ride/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:catch_ride/view/vendor/groom/chat/chat_request_card.dart';

class TrainerRequestsView extends StatefulWidget {
  const TrainerRequestsView({super.key});

  @override
  State<TrainerRequestsView> createState() => _TrainerRequestsViewState();
}

class _TrainerRequestsViewState extends State<TrainerRequestsView> {
  final ChatController controller = Get.put(ChatController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchConversations();
      Get.put(BookingController()).fetchBookings(type: 'received');
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
      ),
      body: Obx(() {
        final bookingController = Get.put(BookingController());
        final chatController = Get.put(ChatController());
        
        // 1. Get Chat Conversations that are requests
        final chatRequests = chatController.conversations.where((c) {
          return c.status == 'request-pending';
        }).toList();

        // 2. Get Pending Bookings that aren't linked to a chat request yet
        final existingBookingIds = chatRequests.map((c) => c.booking?.id).toSet();
        final standaloneBookings = bookingController.receivedBookings.where((b) {
          final isPending = b.status.toLowerCase() == 'pending' || b.status.toLowerCase() == 'requested';
          return isPending && !existingBookingIds.contains(b.id);
        }).toList();

        final bool isEmpty = chatRequests.isEmpty && standaloneBookings.isEmpty;
        final bool isLoading = (chatController.isLoadingConversations.value || bookingController.isLoading.value) && isEmpty;

        return Stack(
          children: [
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (isEmpty)
              RefreshIndicator(
                onRefresh: () async {
                  await chatController.fetchConversations();
                  await bookingController.fetchBookings(type: 'received');
                },
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
                onRefresh: () async {
                  await chatController.fetchConversations();
                  await bookingController.fetchBookings(type: 'received');
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  children: [
                    if (chatRequests.isNotEmpty) ...[
                      const CommonText(
                        'Chat Requests',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF667085),
                      ),
                      const SizedBox(height: 16),
                      ...chatRequests.map((chat) => ChatRequestCard(request: chat)).toList(),
                      const SizedBox(height: 24),
                    ],
                    if (standaloneBookings.isNotEmpty) ...[
                      const CommonText(
                        'Booking Requests',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF667085),
                      ),
                      const SizedBox(height: 16),
                      ...standaloneBookings.map((booking) => RequestCard(booking: booking)).toList(),
                    ],
                  ],
                ),
              ),
            if (chatController.isUpdatingStatus.value)
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

class RequestCard extends StatefulWidget {
  final BookingModel booking;
  const RequestCard({super.key, required this.booking});

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  bool _isAccepting = false;
  bool _isRejecting = false;

  bool get _isBusy => _isAccepting || _isRejecting;

  @override
  Widget build(BuildContext context) {
    final ChatController chatController = Get.put(ChatController());
    final String name = widget.booking.clientName ?? 'Unknown';
    final String role = widget.booking.senderBarnName ?? widget.booking.acceptedByRole ?? 'User';
    final String? avatar = widget.booking.clientImage;

    return Container(
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
                      Row(
                        children: [
                          CommonText(
                            "Trainer : $name",
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
                        url: widget.booking.horseImage,
                        height: 80,
                        width: 80,
                        radius: 8,
                        fit: BoxFit.cover,
                      ),
                      if (widget.booking.type.isNotEmpty)
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
                              widget.booking.type,
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
                              widget.booking.horseName ?? "Booking Request",
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
                                widget.booking.location ?? 'N/A',
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
                              widget.booking.date,
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
                  widget.booking.notes ?? 'No message provided',
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
                            final bookingController = Get.put(BookingController());
                            bool success = await bookingController.updateBookingStatus(
                              widget.booking.id!,
                              'rejected'
                            ) != null;

                            if (mounted) setState(() => _isRejecting = false);

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
                        color: _isRejecting
                            ? Colors.grey.shade100
                            : Colors.white,
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
                            final bookingController = Get.put(BookingController());
                            final result = await bookingController.updateBookingStatus(
                              widget.booking.id!,
                              'confirmed'
                            );

                            if (mounted) setState(() => _isAccepting = false);

                            if (result != null) {
                              // Refresh chat list to reflect acceptance
                              await chatController.fetchConversations();

                              // Open the existing chat thread (same conversation) if it already exists.
                              // Falls back to the normalized ID, avoiding a "new chat" redirect.
                              chatController.openBookingChat(
                                bookingId: widget.booking.id ?? '',
                                otherId: widget.booking.clientId ?? '',
                                otherName: name,
                                otherImage: avatar ?? '',
                              );
                            } else {
                              Get.snackbar('Error', 'Failed to accept booking');
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
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
    );
  }
}
