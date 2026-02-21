import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/widgets/notification_card.dart';
import 'package:catch_ride/view/trainer/barn_manager/barn_manager_approval_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        children: [
          NotificationCard(
            title: 'Barn Manager Request',
            date: 'Just now',
            body:
                'Sarah Connor has requested to manage your barn. Review and approve their access.',
            onTap: () {
              Get.to(() => const BarnManagerApprovalScreen());
            },
            isRead: false,
          ),
          ...List.generate(
            9,
            (index) => NotificationCard(
              title: 'New Booking Request',
              date: '${index + 2}h ago',
              body: 'You have a new booking request from Trainer ${index + 1}.',
              onTap: () {
                // Navigate to booking details
              },
              isRead: true,
            ),
          ),
        ],
      ),
    );
  }
}
