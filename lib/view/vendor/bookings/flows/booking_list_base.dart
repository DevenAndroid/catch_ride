// booking_list_base.dart
// Vendor's tabbed list of upcoming/past service bookings (BookingList[Service])

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_detail_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_request_review_base.dart';

class BookingListBase extends StatelessWidget {
  final VendorServiceConfig service;

  const BookingListBase({super.key, required this.service});

  List<VendorBooking> _byStatus(BookingStatus s) => mockVendorBookings
      .where((b) => b.serviceType == service.type && b.status == s)
      .toList();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${service.verbLabel} Bookings'),
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
            _BookingListView(
              bookings: _byStatus(BookingStatus.pending),
              emptyText: 'No new requests',
              emptyIcon: Icons.inbox_outlined,
              service: service,
            ),
            _BookingListView(
              bookings: _byStatus(BookingStatus.confirmed),
              emptyText: 'No upcoming bookings',
              emptyIcon: Icons.calendar_today_outlined,
              service: service,
            ),
            _BookingListView(
              bookings: [
                ..._byStatus(BookingStatus.completed),
                ..._byStatus(BookingStatus.declined),
                ..._byStatus(BookingStatus.cancelled),
              ],
              emptyText: 'No past bookings',
              emptyIcon: Icons.history_rounded,
              service: service,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _BookingListView extends StatelessWidget {
  final List<VendorBooking> bookings;
  final String emptyText;
  final IconData emptyIcon;
  final VendorServiceConfig service;

  const _BookingListView({
    required this.bookings,
    required this.emptyText,
    required this.emptyIcon,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: AppColors.grey300),
            const SizedBox(height: 16),
            Text(
              emptyText,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) =>
          _BookingCard(booking: bookings[index], service: service),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Booking Card
// ─────────────────────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final VendorBooking booking;
  final VendorServiceConfig service;

  const _BookingCard({required this.booking, required this.service});

  @override
  Widget build(BuildContext context) {
    final isPending = booking.status == BookingStatus.pending;
    final isConfirmed = booking.status == BookingStatus.confirmed;
    final dateStr = DateFormat('EEE, MMM d · h:mm a').format(booking.date);

    return GestureDetector(
      onTap: () =>
          Get.to(() => BookingDetailBase(booking: booking, service: service)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPending
                ? AppColors.mutedGold.withOpacity(0.5)
                : AppColors.grey200,
            width: isPending ? 1.5 : 1,
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
            // ── Header ──────────────────────────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.deepNavy.withOpacity(0.1),
                  child: Text(
                    booking.clientName[0],
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
                        booking.clientName,
                        style: AppTextStyles.titleMedium,
                      ),
                      Text(
                        '${booking.clientRole} · ${booking.horseCount} horse${booking.horseCount > 1 ? 's' : ''}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: booking.status.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking.status.label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: booking.status.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // ── Details ──────────────────────────────────────────────────
            _row(Icons.work_outline_rounded, 'Service', booking.serviceDetail),
            const SizedBox(height: 6),
            _row(Icons.calendar_today_rounded, 'Date', dateStr),
            const SizedBox(height: 6),
            _row(Icons.location_on_outlined, 'Location', booking.location),
            const SizedBox(height: 6),
            _row(Icons.flag_outlined, 'Show', booking.showName),
            const SizedBox(height: 6),
            _row(
              Icons.attach_money_rounded,
              'Rate',
              '${booking.rate} ${service.rateUnit}',
            ),
            if (booking.notes != null) ...[
              const SizedBox(height: 6),
              _row(Icons.notes_rounded, 'Notes', booking.notes!),
            ],

            // ── Actions ──────────────────────────────────────────────────
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.to(
                        () => BookingRequestReviewBase(
                          booking: booking,
                          service: service,
                          acceptMode: false,
                        ),
                      ),
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
                      onPressed: () => Get.to(
                        () => BookingRequestReviewBase(
                          booking: booking,
                          service: service,
                          acceptMode: true,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepNavy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Review & Accept'),
                    ),
                  ),
                ],
              ),
            ],
            if (isConfirmed) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => Get.snackbar(
                  'Messages',
                  'Opening thread with ${booking.clientName}',
                ),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                label: Text('Message ${booking.clientName}'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.deepNavy,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.grey500),
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
}
