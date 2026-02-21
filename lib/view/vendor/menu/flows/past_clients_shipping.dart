import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/inbox/vendor_inbox_models.dart';
import 'package:catch_ride/view/vendor/inbox/vendor_chat_detail_screen.dart';

class PastClientsShippingScreen extends StatelessWidget {
  const PastClientsShippingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for past clients
    final List<Map<String, dynamic>> pastClients = [
      {
        'name': 'Sarah Williams',
        'location': 'Wellington, FL',
        'lastBooking': 'Feb 15, 2026',
        'route': 'Wellington → Ocala',
        'horses': 2,
      },
      {
        'name': 'Michael Davis',
        'location': 'Lexington, KY',
        'lastBooking': 'Jan 22, 2026',
        'route': 'Lexington → Tryon',
        'horses': 4,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Past Clients'), centerTitle: true),
      body: pastClients.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: pastClients.length,
              itemBuilder: (context, index) {
                final client = pastClients[index];
                return _buildClientCard(client);
              },
            ),
    );
  }

  Widget _buildClientCard(Map<String, dynamic> client) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.deepNavy.withOpacity(0.1),
                child: Text(
                  client['name'][0],
                  style: const TextStyle(
                    color: AppColors.deepNavy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(client['name'], style: AppTextStyles.titleMedium),
                    Text(
                      client['location'],
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Get.to(
                    () => VendorChatDetailScreen(
                      thread: VendorThread(
                        id: 'past-${client['name']}',
                        participantName: client['name'],
                        participantRole: VendorParticipantRole.trainer,
                        previewText:
                            'Re-connecting regarding previous shipment...',
                        time: 'Now',
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  color: AppColors.deepNavy,
                ),
                tooltip: 'Message Client',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoSegment('Last Trip', client['lastBooking']),
              _infoSegment('Route', client['route']),
              _infoSegment('Horses', client['horses'].toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoSegment(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.grey500,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 60, color: AppColors.grey200),
          const SizedBox(height: 16),
          Text(
            'No past clients yet',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.grey400),
          ),
          const SizedBox(height: 8),
          Text(
            'Clients will appear here once you\ncomplete a booking.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey400),
          ),
        ],
      ),
    );
  }
}
