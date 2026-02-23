import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/models/booking_model.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/widgets/booking_card.dart';
import 'package:catch_ride/view/trainer/bookings/booking_detail_screen.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bookings'),
          bottom: const TabBar(
            labelColor: AppColors.deepNavy,
            unselectedLabelColor: AppColors.grey500,
            indicatorColor: AppColors.mutedGold,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Accepted'),
              Tab(text: 'Requested'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookingList(BookingStatus.accepted),
            _buildBookingList(BookingStatus.requested),
            _buildBookingList(
              BookingStatus.completed,
            ), // Logic handles completed/cancelled/declined
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(BookingStatus targetStatus) {
    // Filter Mock Data
    List<BookingModel> bookings = mockBookings.where((b) {
      if (targetStatus == BookingStatus.requested) {
        return b.status == BookingStatus.requested;
      } else if (targetStatus == BookingStatus.accepted) {
        return b.status == BookingStatus.accepted;
      } else {
        // Past
        return b.status == BookingStatus.completed ||
            b.status == BookingStatus.cancelled ||
            b.status == BookingStatus.declined;
      }
    }).toList();

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: AppColors.grey300,
            ),
            const SizedBox(height: 16),
            Text(
              'No bookings found',
              style: TextStyle(color: AppColors.grey500),
            ),
            if (targetStatus == BookingStatus.requested)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Check Help Center if you expect requests.',
                  style: TextStyle(color: AppColors.grey400, fontSize: 12),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return BookingCard(
          booking: booking,
          onTap: () {
            // Navigate to unified detail screen
            Get.to(() => BookingDetailScreen(booking: booking));
          },
        );
      },
    );
  }
}
