import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_detail_shipping.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_request_review_shipping.dart';
import 'package:catch_ride/view/vendor/shipping/flows/list_load_shipping.dart';

class BookingsListShippingScreen extends StatefulWidget {
  const BookingsListShippingScreen({super.key});

  @override
  State<BookingsListShippingScreen> createState() =>
      _BookingsListShippingScreenState();
}

class _BookingsListShippingScreenState extends State<BookingsListShippingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final shippingBookings = mockVendorBookings
        .where((b) => b.serviceType == VendorServiceType.shipping)
        .toList();

    final requests = shippingBookings
        .where((b) => b.status == BookingStatus.pending)
        .toList();
    final confirmed = shippingBookings
        .where((b) => b.status == BookingStatus.confirmed)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Shipping Bookings'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.deepNavy,
          unselectedLabelColor: AppColors.grey400,
          indicatorColor: AppColors.deepNavy,
          tabs: [
            Tab(text: 'Requests (${requests.length})'),
            Tab(text: 'Confirmed (${confirmed.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(requests, isRequest: true),
          _buildList(confirmed, isRequest: false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const ListLoadShippingScreen()),
        backgroundColor: AppColors.deepNavy,
        icon: const Icon(Icons.list_alt_rounded),
        label: const Text('My Loads'),
      ),
    );
  }

  Widget _buildList(List<VendorBooking> list, {required bool isRequest}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_outlined, size: 64, color: AppColors.grey200),
            const SizedBox(height: 16),
            Text(
              'No ${isRequest ? 'pending requests' : 'upcoming trips'}',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.grey400),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final b = list[index];
        return _BookingTile(booking: b, isRequest: isRequest);
      },
    );
  }
}

class _BookingTile extends StatelessWidget {
  final VendorBooking booking;
  final bool isRequest;

  const _BookingTile({required this.booking, required this.isRequest});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isRequest) {
          Get.to(() => BookingRequestReviewShippingScreen(booking: booking));
        } else {
          Get.to(() => BookingShippingDetailScreen(booking: booking));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM d').format(booking.date),
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.deepNavy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (booking.relatedLoadId != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.deepNavy.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'LOAD #${booking.relatedLoadId}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepNavy,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(booking.location, style: AppTextStyles.titleMedium),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 14,
                  color: AppColors.grey500,
                ),
                const SizedBox(width: 4),
                Text(
                  '${booking.clientName} · ${booking.horseCount} Horse${booking.horseCount > 1 ? 's' : ''}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            if (isRequest) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'NEW REQUEST',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mutedGold,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Review',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepNavy,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: AppColors.deepNavy,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
