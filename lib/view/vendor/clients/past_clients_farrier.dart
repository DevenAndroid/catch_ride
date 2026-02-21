import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

class PastClientRecord {
  final String name;
  final String barnName;
  final String lastService;
  final String date;
  final String initials;

  PastClientRecord({
    required this.name,
    required this.barnName,
    required this.lastService,
    required this.date,
    required this.initials,
  });
}

class PastClientsFarrierScreen extends StatelessWidget {
  PastClientsFarrierScreen({super.key});

  final List<PastClientRecord> _clients = [
    PastClientRecord(
      name: 'Sarah Jenkins',
      barnName: 'Willow Creek Stables',
      lastService: 'Full Set + Aluminum',
      date: 'Jan 12, 2024',
      initials: 'SJ',
    ),
    PastClientRecord(
      name: 'Michael Chen',
      barnName: 'Evergreen Equestrian',
      lastService: 'Front Shoes + Trimming',
      date: 'Dec 28, 2023',
      initials: 'MC',
    ),
    PastClientRecord(
      name: 'Linda Ross',
      barnName: 'Blue Ribbon Farm',
      lastService: 'Corrective Shoeing',
      date: 'Dec 15, 2023',
      initials: 'LR',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Past Clients'), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: _clients.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final client = _clients[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.deepNavy.withOpacity(0.1),
                  child: Text(
                    client.initials,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.deepNavy,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client.name, style: AppTextStyles.titleMedium),
                      Text(
                        client.barnName,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last: ${client.lastService}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.deepNavy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      client.date,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.deepNavy,
                        size: 20,
                      ),
                      onPressed: () {
                        // In a real app, find or create the thread
                        Get.snackbar(
                          'Message',
                          'Opening chat with ${client.name}...',
                        );
                      },
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
