import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

class PastClientsBodyworkScreen extends StatelessWidget {
  const PastClientsBodyworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock past clients
    final pastClients = [
      {
        'name': 'Sarah Williams',
        'horse': 'Midnight Star',
        'date': 'Feb 15, 2026',
        'service': 'Sports Massage',
      },
      {
        'name': 'Michael Davis',
        'horse': 'Apollo',
        'date': 'Jan 28, 2026',
        'service': 'Chiropractic',
      },
      {
        'name': 'Lisa Chen',
        'horse': 'Diamond',
        'date': 'Dec 10, 2025',
        'service': 'PEMF Therapy',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Past Clients'), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: pastClients.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final client = pastClients[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.mutedGold.withOpacity(0.2),
                  child: Text(
                    client['name']!.substring(0, 1),
                    style: const TextStyle(
                      color: AppColors.mutedGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client['name']!, style: AppTextStyles.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        '${client['service']} • ${client['horse']} • ${client['date']}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Get.snackbar(
                      'Message',
                      'Opening chat with ${client['name']}...',
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  color: AppColors.deepNavy,
                  tooltip: 'Message past client',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
