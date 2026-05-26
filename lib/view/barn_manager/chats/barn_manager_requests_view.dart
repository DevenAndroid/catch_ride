import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'barn_manager_single_chat_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/utils/booking_controller_lookup.dart';
import 'package:catch_ride/models/booking_model.dart';
import 'package:catch_ride/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:catch_ride/view/vendor/groom/chat/chat_request_card.dart';

class BarnManagerRequestsView extends StatefulWidget {
  const BarnManagerRequestsView({super.key});

  @override
  State<BarnManagerRequestsView> createState() =>
      _BarnManagerRequestsViewState();
}

class _BarnManagerRequestsViewState extends State<BarnManagerRequestsView> {
  final ChatController controller = Get.find<ChatController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchConversations();
      lookupBookingController().fetchBookings(type: 'received');
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
        final bookingController = lookupBookingController();
        final chatController = Get.find<ChatController>();

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
                      ...standaloneBookings.map((booking) => RequestCard(request: booking)).toList(),
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


// ---------------------------------------------------------------------------


class RequestCard extends StatefulWidget {
  final BookingModel request;
  const RequestCard({super.key, required this.request});

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  final ChatController controller = Get.find<ChatController>();
  bool _isRejecting = false;
  bool _isAccepting = false;

  bool get _isBusy => _isRejecting || _isAccepting;

  @override
  Widget build(BuildContext context) {
    final String name = widget.request.clientName ?? 'Unknown';
    final String role = widget.request.senderBarnName ?? widget.request.acceptedByRole ?? 'Client';
    final String? avatar = widget.request.clientImage;

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
          // ── Header ─────────────────────────────────────────────
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

          // ── Horse Details ───────────────────────────────────────
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
                        url: widget.request.horseImage,
                        height: 80,
                        width: 80,
                        radius: 8,
                        fit: BoxFit.cover,
                      ),
                      if (widget.request.type.isNotEmpty)
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
                              widget.request.type,
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
                                widget.request.horseName ?? "Booking Request",
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
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
                                widget.request.location ?? 'N/A',
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
                              widget.request.date,
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

          // ── Request Message ─────────────────────────────────────
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
                  widget.request.notes ?? 'No message provided',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  maxLines: 5,
                ),
              ],
            ),
          ),

          // ── Action Buttons ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                // Reject
                Expanded(
                  child: GestureDetector(
                    onTap: _isBusy
                        ? null
                        : () async {
                            Get.dialog(
                              AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: const CommonText(
                                  'Confirm Rejection',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                content: const CommonText(
                                  'Are you sure you want to reject this request?',
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const CommonText(
                                      'Cancel',
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Get.back(); // Close dialog
                                      setState(() => _isRejecting = true);
                                      final bookingController = lookupBookingController();
                                      final result = await bookingController.updateBookingStatus(
                                        widget.request.id!,
                                        'rejected'
                                      );

                                      if (mounted) setState(() => _isRejecting = false);

                                      if (result != null) {
                                        controller.fetchConversations();
                                        bookingController.fetchBookings(type: 'received');
                                        Get.snackbar(
                                          'Success',
                                          'Request declined',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.black87,
                                          colorText: Colors.white,
                                          margin: const EdgeInsets.all(16),
                                        );
                                      }
                                    },
                                    child: const CommonText(
                                      'Reject',
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
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

                // Accept
                Expanded(
                  child: GestureDetector(
                    onTap: _isBusy
                        ? null
                        : () async {
                            setState(() => _isAccepting = true);
                            final bookingController = lookupBookingController();
                            final result = await bookingController.updateBookingStatus(
                              widget.request.id!,
                              'confirmed'
                            );

                            if (mounted) setState(() => _isAccepting = false);

                            if (result != null && result is Map) {
                              final String? generalId = result['conversationId'];
                              controller.fetchConversations();
                              bookingController.fetchBookings(type: 'received');

                              Get.to(() => BarnManagerSingleChatView(
                                    name: name,
                                    image: avatar ?? '',
                                    conversationId: generalId ?? '',
                                    otherId: widget.request.clientId,
                                  ));
                            } else {
                              Get.snackbar('Error', 'Failed to accept booking');
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _isAccepting
                            ? const Color(0xFF0e7a68)
                            : const Color(0xff12937E),
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
