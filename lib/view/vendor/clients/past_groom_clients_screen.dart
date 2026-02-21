import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

class PastGroomClientsScreen extends StatelessWidget {
  const PastGroomClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> pastClients = [
      {
        'name': 'Sarah Williams',
        'initials': 'SW',
        'role': 'Trainer',
        'lastJob': 'WEF Week 4 - Full Show Grooming',
        'date': 'Feb 12, 2026',
      },
      {
        'name': 'Emily Johnson',
        'initials': 'EJ',
        'role': 'Barn Manager',
        'lastJob': 'Ocala HITS - Day Fill-in',
        'date': 'Feb 5, 2026',
      },
      {
        'name': 'Michael Davis',
        'initials': 'MD',
        'role': 'Trainer',
        'lastJob': 'Private Barn - Clipping (3 horses)',
        'date': 'Jan 22, 2026',
      },
      {
        'name': 'Rachel Brooks',
        'initials': 'RB',
        'role': 'Barn Manager',
        'lastJob': 'Tryon Spring - Assistant Groom',
        'date': 'Dec 15, 2025',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Past Clients'), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: pastClients.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final client = pastClients[index];
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
                    client['initials'],
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.deepNavy,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            client['name'],
                            style: AppTextStyles.titleMedium,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.grey100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              client['role'],
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.grey600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        client['lastJob'],
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                      Text(
                        'Completed: ${client['date']}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey400,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Get.snackbar(
                      'Messages',
                      'Opening chat with ${client['name']}',
                    );
                  },
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.deepNavy,
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
