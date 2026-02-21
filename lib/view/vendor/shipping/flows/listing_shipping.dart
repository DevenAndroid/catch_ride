import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/shipping/flows/load_models.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/view/vendor/inbox/vendor_inbox_models.dart';
import 'package:catch_ride/view/vendor/inbox/vendor_chat_detail_screen.dart';

import '../../profile/flows/profile_page_shipping.dart';

class ListingShippingScreen extends StatelessWidget {
  final ShippingLoad load;
  const ListingShippingScreen({super.key, required this.load});

  @override
  Widget build(BuildContext context) {
    bool isDisabled =
        load.status == LoadStatus.full || load.status == LoadStatus.closed;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Load Details'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (Shipper Info)
            _buildShipperHeader(),
            const Divider(thickness: 8, color: AppColors.grey100),

            // 2. Load Summary
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Load Summary', style: AppTextStyles.titleLarge),
                      _statusBadge(load.status),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _detailRow(Icons.location_on_outlined, 'Origin', load.origin),
                  const SizedBox(height: 16),
                  _detailRow(
                    Icons.flag_outlined,
                    'Destinations',
                    load.destinations.join('\n'),
                  ),
                  const SizedBox(height: 16),
                  _detailRow(
                    Icons.calendar_today_outlined,
                    'Date / Range',
                    load.dateRange,
                  ),
                  const SizedBox(height: 16),
                  _detailRow(
                    Icons.pets,
                    'Available Slots',
                    '${load.remainingSlots} of ${load.totalSlots} horses',
                  ),
                  const SizedBox(height: 16),
                  _detailRow(
                    Icons.local_shipping_outlined,
                    'Equipment',
                    load.equipmentType,
                  ),
                  const SizedBox(height: 16),
                  _detailRow(
                    Icons.alt_route_outlined,
                    'Stops Allowed',
                    load.allowsStops ? 'Yes' : 'Direct Route Only',
                  ),

                  if (load.notes != null && load.notes!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Notes', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    Text(load.notes!, style: AppTextStyles.bodyMedium),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(isDisabled),
    );
  }

  Widget _buildShipperHeader() {
    return InkWell(
      onTap: () =>
          Get.to(() => const ProfilePageShippingScreen(isOwnProfile: false)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.deepNavy,
              child: Text('BC', style: TextStyle(color: AppColors.mutedGold)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cole Equine Transport',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ocala, FL • Licensed Shipper',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _badge('USDOT Registered'),
                      const SizedBox(width: 8),
                      _badge('Commercial Ins'),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.grey400),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, size: 12, color: AppColors.successGreen),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.successGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.mutedGold, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.grey500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(LoadStatus status) {
    Color color;
    String label;
    switch (status) {
      case LoadStatus.open:
        color = AppColors.successGreen;
        label = 'OPEN';
        break;
      case LoadStatus.limited:
        color = AppColors.mutedGold;
        label = 'LIMITED';
        break;
      case LoadStatus.full:
        color = AppColors.softRed;
        label = 'FULL';
        break;
      case LoadStatus.closed:
        color = AppColors.grey500;
        label = 'CLOSED';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildBottomActions(bool isDisabled) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Get.to(
                  () => VendorChatDetailScreen(
                    thread: VendorThread(
                      id: 'new-inquiry-${load.id}',
                      participantName: 'Sarah Williams',
                      participantRole: VendorParticipantRole.trainer,
                      previewText:
                          'Hello, I saw your load from ${load.origin} and would like to inquire about space.',
                      time: 'Now',
                      hasSystemMessage: true,
                      systemMessageText: 'Load Inquiry',
                      relatedLoadId: load.id,
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.deepNavy),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Message Shipper',
                style: TextStyle(color: AppColors.deepNavy),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: CustomButton(
              text: isDisabled ? 'No Remaining Slots' : 'Request Booking',
              onPressed: isDisabled
                  ? null
                  : () => Get.snackbar(
                      'Booking',
                      'Initiating booking request...',
                    ),
              backgroundColor: isDisabled
                  ? AppColors.grey400
                  : AppColors.deepNavy,
            ),
          ),
        ],
      ),
    );
  }
}
