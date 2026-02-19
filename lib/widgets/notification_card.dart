
import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final String date;
  final String body;
  final bool isRead;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.title,
    required this.date,
    required this.body,
    required this.onTap,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isRead ? Colors.white : AppColors.warmCream.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.mutedGold.withOpacity(0.2),
          child: Icon(Icons.notifications, color: AppColors.mutedGold),
        ),
        title: Text(title, style: AppTextStyles.titleMedium),
        subtitle: Text(body, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodyMedium),
        trailing: Text(date, style: AppTextStyles.bodySmall),
      ),
    );
  }
}
