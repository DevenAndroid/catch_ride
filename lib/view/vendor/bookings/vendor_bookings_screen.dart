import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/utils/date_picker_helper.dart';

// Mock vendor booking data
final List<Map<String, dynamic>> _mockVendorBookings = [
  {
    'id': 'VB001',
    'clientName': 'Sarah Williams',
    'horseName': 'Midnight Star',
    'service': 'Full Day Grooming',
    'date': DateTime(2026, 3, 5, 8, 0),
    'location': 'Wellington Equestrian Center',
    'rate': '\$200',
    'status': 'pending',
  },
  {
    'id': 'VB002',
    'clientName': 'Emily Johnson',
    'horseName': 'Royal Knight',
    'service': 'Braiding (Mane + Tail)',
    'date': DateTime(2026, 3, 7, 6, 30),
    'location': 'WEF Grounds',
    'rate': '\$65',
    'status': 'pending',
  },
  {
    'id': 'VB003',
    'clientName': 'Michael Davis',
    'horseName': 'Thunder',
    'service': 'Full Body Clipping',
    'date': DateTime(2026, 3, 2, 10, 0),
    'location': 'Palm Beach Stables',
    'rate': '\$150',
    'status': 'confirmed',
  },
  {
    'id': 'VB004',
    'clientName': 'Lisa Chen',
    'horseName': 'Goldie',
    'service': 'Full Day Grooming',
    'date': DateTime(2026, 2, 28, 7, 0),
    'location': 'Global Dressage Festival',
    'rate': '\$200',
    'status': 'completed',
  },
];

class VendorBookingsScreen extends StatelessWidget {
  const VendorBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bookings'),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            labelColor: AppColors.deepNavy,
            unselectedLabelColor: AppColors.grey500,
            indicatorColor: AppColors.mutedGold,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Requests'),
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookingList('pending'),
            _buildBookingList('confirmed'),
            _buildBookingList('completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(String statusFilter) {
    final filtered = _mockVendorBookings
        .where((b) => b['status'] == statusFilter)
        .toList();

    if (filtered.isEmpty) {
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
              statusFilter == 'pending'
                  ? 'No new booking requests'
                  : statusFilter == 'confirmed'
                  ? 'No upcoming bookings'
                  : 'No past bookings',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final booking = filtered[index];
        return _VendorBookingCard(booking: booking);
      },
    );
  }
}

class _VendorBookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const _VendorBookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final status = booking['status'] as String;
    final date = booking['date'] as DateTime;
    final isPending = status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending
              ? AppColors.mutedGold.withOpacity(0.5)
              : AppColors.grey200,
        ),
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
          // Header Row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.grey200,
                child: Text(
                  booking['clientName'].toString().substring(0, 1),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.deepNavy,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['clientName'],
                      style: AppTextStyles.titleMedium,
                    ),
                    Text(
                      'Horse: ${booking['horseName']}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel(status),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _statusColor(status),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Service & Details
          _buildDetailRow(Icons.work_outline, 'Service', booking['service']),
          const SizedBox(height: 8),
          _buildDetailRow(
            Icons.calendar_today,
            'Date & Time',
            AppDateFormatter.format(date),
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            Icons.location_on_outlined,
            'Location',
            booking['location'],
          ),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.attach_money, 'Rate', booking['rate']),

          // Action Buttons for Pending
          if (isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.snackbar(
                        'Declined',
                        'Booking request declined',
                        backgroundColor: AppColors.softRed,
                        colorText: Colors.white,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.softRed),
                      foregroundColor: AppColors.softRed,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.snackbar(
                        'Accepted!',
                        'Booking confirmed for ${booking['clientName']}',
                        backgroundColor: AppColors.successGreen,
                        colorText: Colors.white,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],

          // Completed actions
          if (status == 'completed') ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.receipt_long_outlined, size: 18),
                label: const Text('View Receipt'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.deepNavy,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey500),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.mutedGold;
      case 'confirmed':
        return AppColors.successGreen;
      case 'completed':
        return AppColors.deepNavy;
      default:
        return AppColors.grey500;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'New Request';
      case 'confirmed':
        return 'Confirmed';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }
}
