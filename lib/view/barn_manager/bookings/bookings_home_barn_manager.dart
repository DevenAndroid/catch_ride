import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/models/booking_model.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/widgets/booking_card.dart';
import 'package:catch_ride/view/barn_manager/bookings/booking_details_barn_manager.dart';

class BookingsHomeBarnManager extends StatelessWidget {
  const BookingsHomeBarnManager({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trainer\'s Bookings'),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: AppColors.deepNavy,
            unselectedLabelColor: AppColors.grey500,
            indicatorColor: AppColors.mutedGold,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Confirmed'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookingList(BookingStatus.requested),
            _buildBookingList(BookingStatus.accepted),
            _buildBookingList(BookingStatus.completed),
            _buildBookingList(BookingStatus.cancelled),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(BookingStatus targetStatus) {
    // Filter Mock Data (reusing mockBookings from models/booking_model.dart)
    List<BookingModel> bookings = mockBookings.where((b) {
      if (targetStatus == BookingStatus.cancelled) {
        return b.status == BookingStatus.cancelled ||
            b.status == BookingStatus.declined;
      }
      return b.status == targetStatus;
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
              'No bookings in this category',
              style: TextStyle(color: AppColors.grey500),
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
            Get.to(() => BookingDetailsBarnManager(booking: booking));
          },
        );
      },
    );
  }
}
