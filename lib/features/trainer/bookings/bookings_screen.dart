import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/widgets/booking_card.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Expanded tabs according to flow
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: AppColors.deepNavy,
            unselectedLabelColor: AppColors.grey500,
            indicatorColor: AppColors.mutedGold,
            tabs: [
              Tab(text: 'All'), // Overview
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookingList('All'),
            _buildBookingList('Pending'),
            _buildBookingList('Accepted'),
            _buildBookingList('Completed'),
            _buildBookingList('Cancelled'),
          ],
        ),

        // Quick Action FAB for vendor booking flow shortcut if needed
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // Navigate to Vendor Search or Request
            Get.snackbar('New Booking', 'Navigate to Explore to find vendors');
          },
          label: const Text('Book Service'),
          icon: const Icon(Icons.add),
          backgroundColor: AppColors.deepNavy,
        ),
      ),
    );
  }

  Widget _buildBookingList(String status) {
    // Mock Data Logic
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        String currentStatus = status == 'All'
            ? (index % 2 == 0 ? 'Pending' : 'Accepted')
            : status;

        return BookingCard(
          title: index % 2 == 0
              ? 'Full Body Clip - Vendor Name'
              : 'Horse Trial - Client Name',
          date: 'Nov ${10 + index}, 2023', // Upcoming
          status: currentStatus,
          onTap: () {
            // Navigate to Detail
            // Get.to(() => BookingDetailScreen(id: index));
          },
        );
      },
    );
  }
}
