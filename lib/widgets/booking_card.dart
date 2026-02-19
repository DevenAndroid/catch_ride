
import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

class BookingCard extends StatelessWidget {
  final String title;
  final String date;
  final String status;
  final VoidCallback onTap;

  const BookingCard({
    super.key,
    required this.title,
    required this.date,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        onTap: onTap,
        title: Text(title, style: AppTextStyles.titleMedium),
        subtitle: Text(date, style: AppTextStyles.bodyMedium),
        trailing: Chip(label: Text(status)),
      ),
    );
  }
}
