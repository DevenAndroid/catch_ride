
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/widgets/notification_card.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return NotificationCard(
            title: 'New Booking Request',
            date: '2h ago',
            body: 'You have a new booking request from John Doe.',
            onTap: () {
              // Navigate to booking details
            },
            isRead: index > 2, // Example logic
          );
        },
      ),
    );
  }
}
