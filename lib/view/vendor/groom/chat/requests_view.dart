import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/booking_controller.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chat_request_card.dart';
import 'standalone_booking_card.dart';

class RequestsView extends StatefulWidget {
  const RequestsView({super.key});

  @override
  State<RequestsView> createState() => _RequestsViewState();
}

class _RequestsViewState extends State<RequestsView> {
  final BookingController bookingController = Get.put(BookingController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final chatController = Get.find<ChatController>();
      await chatController.fetchConversations();
      await bookingController.fetchBookings(type: 'received');
    });
  }

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.put(ChatController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1F2937), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText('Requests', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: Obx(() {
        // 1. Get Chat Conversations that are requests
        final chatRequests = controller.conversations.where((c) {
          final otherUserRole = c.otherUser?.role?.toLowerCase();
          final isTargetRole = otherUserRole == 'trainer' || otherUserRole == 'barn_manager';
          return c.status == 'request-pending' && isTargetRole;
        }).toList();

        // 2. Get Pending Bookings that aren't linked to a chat request yet
        final existingBookingIds = chatRequests.map((c) => c.booking?.id).toSet();
        final standaloneBookings = bookingController.receivedBookings.where((b) {
          return b.status.toLowerCase() == 'pending' && !existingBookingIds.contains(b.id);
        }).toList();

        return Stack(
          children: [
            if (controller.isLoadingConversations.value && chatRequests.isEmpty && standaloneBookings.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (chatRequests.isEmpty && standaloneBookings.isEmpty)
              RefreshIndicator(
                onRefresh: () async {
                  await controller.fetchConversations();
                  await bookingController.fetchBookings(type: 'received');
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mail_outline, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            const CommonText('No pending requests', color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              RefreshIndicator(
                onRefresh: () async {
                  await controller.fetchConversations();
                  await bookingController.fetchBookings(type: 'received');
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (chatRequests.isNotEmpty) ...[
                      const CommonText('Chat Requests', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF667085)),
                      const SizedBox(height: 16),
                      ...chatRequests.map((chat) => ChatRequestCard(request: chat)).toList(),
                      const SizedBox(height: 24),
                    ],
                    if (standaloneBookings.isNotEmpty) ...[
                      const CommonText('Direct Bookings', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF667085)),
                      const SizedBox(height: 16),
                      ...standaloneBookings
                          .map(
                            (booking) => StandaloneBookingCard(
                              booking: booking,
                              onAction: () {
                                controller.fetchConversations();
                                bookingController.fetchBookings(type: 'received');
                              },
                            ),
                          ),
                    ],
                  ],
                ),
              ),
            if (controller.isUpdatingStatus.value)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      }),
    );
  }
}
