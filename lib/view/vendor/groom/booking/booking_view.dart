import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/booking_controller.dart';
import 'package:catch_ride/models/booking_model.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingView extends StatefulWidget {
  const BookingView({super.key});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  final controller = Get.put(BookingController());
  final chatController = Get.put(ChatController());
  int _selectedTab = 0; // 0 for Upcoming, 1 for Past Clients

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    controller.fetchBookings(type: 'received');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const CommonText(
          'Bookings',
          fontSize: AppTextSizes.size24,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.receivedBookings.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredBookings = controller.receivedBookings.where((b) {
          if (_selectedTab == 0) {
            return b.status.toLowerCase() == 'pending' || b.status.toLowerCase() == 'confirmed' || b.status.toLowerCase() == 'accepted';
          } else {
            return b.status.toLowerCase() == 'completed';
          }
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    _buildTab('Upcoming', 0),
                    _buildTab('Past Clients', 1),
                  ],
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _fetchData(),
                child: filteredBookings.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(height: Get.height * 0.2),
                        const Center(child: CommonText('No bookings found', color: AppColors.textSecondary)),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: filteredBookings.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final booking = filteredBookings[index];
                        return _buildBookingCard(booking);
                      },
                    ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          alignment: Alignment.center,
          child: CommonText(
            label,
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: AppTextSizes.size14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonImageView(
                url: booking.clientImage ?? booking.horseImage ?? '',
                height: 68,
                width: 68,
                shape: BoxShape.circle,
                isUserImage: true,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      'Trainer : ${booking.trainerName ?? 'N/A'}',
                      fontSize: AppTextSizes.size16,
                      fontWeight: FontWeight.bold,
                    ),
                    if (booking.horseName != null) ...[
                      const SizedBox(height: 2),
                      CommonText(
                        'Horse : ${booking.horseName}',
                        fontSize: AppTextSizes.size14,
                        color: AppColors.textSecondary,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(child: CommonText(booking.location ?? 'N/A', fontSize: AppTextSizes.size12, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        CommonText(booking.date, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: CommonText(
                  booking.type,
                  fontSize: AppTextSizes.size12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (booking.notes != null && booking.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            CommonText(
              'NOTE : ${booking.notes}',
              fontSize: AppTextSizes.size14,
              color: AppColors.textPrimary,
            ),
          ],
          if (booking.status.toLowerCase() == 'confirmed' || booking.status.toLowerCase() == 'accepted') ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  if (booking.id != null && booking.clientId != null) {
                    chatController.openBookingChat(
                      bookingId: booking.id!,
                      otherId: booking.clientId!,
                      otherName: booking.clientName ?? 'Client',
                      otherImage: booking.clientImage ?? '',
                    );
                  } else {
                    Get.snackbar(
                      'Chat Unavailable',
                      'Conversation details are not properly loaded for this booking.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.secondary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.chat_bubble_outline, color: AppColors.secondary, size: 20),
                    SizedBox(width: 8),
                    CommonText(
                      'Message',
                      color: AppColors.secondary,
                      fontSize: AppTextSizes.size16,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
