import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

class _PastClient {
  final String name;
  final String date;
  final String serviceDetails;
  final bool hasReview;

  _PastClient({
    required this.name,
    required this.date,
    required this.serviceDetails,
    this.hasReview = false,
  });
}

class PastClientsClippingScreen extends StatefulWidget {
  const PastClientsClippingScreen({super.key});

  @override
  State<PastClientsClippingScreen> createState() =>
      _PastClientsClippingScreenState();
}

class _PastClientsClippingScreenState extends State<PastClientsClippingScreen> {
  // Mock data representing previous clipping bookings
  final List<_PastClient> _pastClients = [
    _PastClient(
      name: 'Sarah Williams (Wellington, Barn 4)',
      date: 'Feb 12, 2026',
      serviceDetails: '2 Full Body Clips, 1 Touch Up',
      hasReview: true,
    ),
    _PastClient(
      name: 'Michael Davis (Ocala WEC)',
      date: 'Jan 28, 2026',
      serviceDetails: '1 Hunter Clip, Bath Prep',
    ),
    _PastClient(
      name: 'Emily Johnson (Tryon)',
      date: 'Dec 05, 2025',
      serviceDetails: '3 Trace Clips',
      hasReview: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Past Clients'), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: _pastClients.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final client = _pastClients[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        client.name,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.deepNavy,
                        ),
                      ),
                    ),
                    if (client.hasReview)
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.mutedGold,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Booked: ${client.date}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  client.serviceDetails,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.snackbar(
                        'Message Sent',
                        'Opening message thread with ${client.name.split(" ")[0]}',
                        backgroundColor: AppColors.deepNavy,
                        colorText: Colors.white,
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline, size: 20),
                    label: const Text(
                      'Message Past Client',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.deepNavy,
                      side: const BorderSide(color: AppColors.deepNavy),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
