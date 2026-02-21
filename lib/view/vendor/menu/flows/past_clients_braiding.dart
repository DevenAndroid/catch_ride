import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

class _PastClientMock {
  final String name;
  final String date;
  final String horseCount;
  final String location;
  final String photo;

  _PastClientMock({
    required this.name,
    required this.date,
    required this.horseCount,
    required this.location,
    required this.photo,
  });
}

class PastClientsBraiderScreen extends StatelessWidget {
  const PastClientsBraiderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_PastClientMock> pastClients = [
      _PastClientMock(
        name: 'Sarah Williams',
        date: 'Oct 12-14, 2024',
        horseCount: '3 Horses',
        location: 'Wellington, FL',
        photo: 'assets/images/home_banner.png',
      ),
      _PastClientMock(
        name: 'Emily Johnson',
        date: 'Sep 3-5, 2024',
        horseCount: '1 Horse',
        location: 'Ocala WEC, FL',
        photo: 'assets/images/home_banner.png',
      ),
      _PastClientMock(
        name: 'Michael Davis',
        date: 'Aug 20-22, 2024',
        horseCount: '5 Horses',
        location: 'Devon, PA',
        photo: 'assets/images/home_banner.png',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Past Clients'), centerTitle: true),
      backgroundColor: AppColors.grey50,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: pastClients.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final c = pastClients[index];
          return _buildClientCard(c);
        },
      ),
    );
  }

  Widget _buildClientCard(_PastClientMock client) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage(client.photo),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.deepNavy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Trainer',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: AppColors.grey100),
          const SizedBox(height: 16),
          _infoRow(Icons.calendar_today_outlined, client.date),
          const SizedBox(height: 8),
          _infoRow(Icons.pets_outlined, client.horseCount),
          const SizedBox(height: 8),
          _infoRow(Icons.location_on_outlined, client.location),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      'Message',
                      'Opening chat thread with ${client.name}...',
                      icon: const Icon(Icons.chat_bubble_outline),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Message Past Client'),
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
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey500),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
