import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/shipping/flows/load_models.dart';
import 'package:catch_ride/view/vendor/shipping/flows/create_load_shipping.dart';
import 'package:catch_ride/widgets/custom_button.dart';

class ListLoadShippingScreen extends StatefulWidget {
  const ListLoadShippingScreen({super.key});

  @override
  State<ListLoadShippingScreen> createState() => _ListLoadShippingScreenState();
}

class _ListLoadShippingScreenState extends State<ListLoadShippingScreen> {
  final List<ShippingLoad> _loads = [
    ShippingLoad(
      id: '1',
      shipperId: 'v123',
      origin: 'Wellington, FL',
      destinations: ['Lexington, KY', 'Aiken, SC'],
      startDate: DateTime(2026, 3, 10),
      endDate: DateTime(2026, 3, 12),
      totalSlots: 6,
      remainingSlots: 4,
      equipmentType: 'Air Ride Gooseneck',
      status: LoadStatus.open,
    ),
    ShippingLoad(
      id: '2',
      shipperId: 'v123',
      origin: 'Ocala, FL',
      destinations: ['Tryon, NC'],
      startDate: DateTime(2026, 3, 15),
      endDate: DateTime(2026, 3, 15),
      totalSlots: 4,
      remainingSlots: 0,
      equipmentType: 'Box Truck',
      status: LoadStatus.full,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Manage Loads'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const CreateLoadShippingScreen()),
        backgroundColor: AppColors.deepNavy,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Post a Load', style: TextStyle(color: Colors.white)),
      ),
      body: _loads.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _loads.length,
              itemBuilder: (context, index) {
                return _buildLoadCard(_loads[index]);
              },
            ),
    );
  }

  Widget _buildLoadCard(ShippingLoad load) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () => Get.to(() => CreateLoadShippingScreen(existingLoad: load)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statusBadge(load.status),
                  _slotBadge(load.remainingSlots, load.totalSlots),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${load.origin} → ${load.destinationSummary}',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.deepNavy,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.grey500,
                  ),
                  const SizedBox(width: 8),
                  Text(load.dateRange, style: AppTextStyles.bodyMedium),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    size: 16,
                    color: AppColors.grey500,
                  ),
                  const SizedBox(width: 8),
                  Text(load.equipmentType, style: AppTextStyles.bodyMedium),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // Logic to duplicate load
                      Get.snackbar('Success', 'Load duplicated');
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Duplicate'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => Get.to(
                      () => CreateLoadShippingScreen(existingLoad: load),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
        border: Border.all(color: color.withOpacity(0.4)),
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

  Widget _slotBadge(int remaining, int total) {
    return Row(
      children: [
        const Icon(Icons.pets, size: 14, color: AppColors.grey400),
        const SizedBox(width: 4),
        Text(
          '$remaining / $total slots left',
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 64,
            color: AppColors.grey200,
          ),
          const SizedBox(height: 16),
          Text(
            'No loads posted yet.',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.grey400),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Post Your First Load',
            onPressed: () => Get.to(() => const CreateLoadShippingScreen()),
          ),
        ],
      ),
    );
  }
}
