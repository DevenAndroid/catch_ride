import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/booking_controller.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/chat_controller.dart';

class UpcomingClientsView extends StatefulWidget {
  const UpcomingClientsView({super.key});

  @override
  State<UpcomingClientsView> createState() => _UpcomingClientsViewState();
}

class _UpcomingClientsViewState extends State<UpcomingClientsView> {
  final controller = Get.put(BookingController());
  final chatController = Get.put(ChatController());

  @override
  void initState() {
    super.initState();
    controller.fetchBookings(type: 'received', time: 'upcoming', status: 'confirmed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText('Upcoming Clients', fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.receivedBookings.isEmpty) {
          return const Center(child: CommonText('No upcoming clients found', color: AppColors.textSecondary));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.receivedBookings.length,
          itemBuilder: (context, index) {
            final booking = controller.receivedBookings[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildClientCard(
                name: booking.trainerName ?? booking.clientName ?? 'N/A',
                service: booking.type.toUpperCase(),
                location: booking.location ?? 'N/A',
                date: booking.date,
                note: booking.notes ?? 'No notes provided',
                imageUrl: booking.horseImage ?? booking.clientImage ?? booking.trainerImage ?? '',
                onMessage: () {
                   if (booking.id != null && booking.clientId != null) {
                      chatController.openBookingChat(
                        bookingId: booking.id!,
                        otherId: booking.clientId!,
                        otherName: booking.trainerName ?? booking.clientName ?? 'Client',
                        otherImage: booking.clientImage ?? booking.trainerImage ?? '',
                      );
                    } else {
                      Get.snackbar(
                        'Chat Unavailable',
                        'Conversation details are not properly loaded for this booking.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                },
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildClientCard({
    required String name,
    required String service,
    required String location,
    required String date,
    required String note,
    required String imageUrl,
    required VoidCallback onMessage,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: CommonImageView(url: imageUrl, width: 60, height: 60, fit: BoxFit.cover, isUserImage: true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CommonText(name, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: CommonText(service, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        CommonText(location, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        CommonText(date, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CommonText('Note: $note', fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onMessage,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF8B4444)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.chat_bubble_outline, size: 18, color: Color(0xFF8B4444)),
                  SizedBox(width: 8),
                  CommonText('Message', color: Color(0xFF8B4444), fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
