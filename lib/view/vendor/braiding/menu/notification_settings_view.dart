import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationSettingsView extends StatefulWidget {
  const NotificationSettingsView({super.key});

  @override
  State<NotificationSettingsView> createState() => _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends State<NotificationSettingsView> {
  bool _isPushEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText('Notifications', fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_none_outlined, color: AppColors.textPrimary, size: 24),
                  const SizedBox(width: 16),
                  const Expanded(child: CommonText('Push Notification', fontSize: AppTextSizes.size16, fontWeight: FontWeight.w500)),
                  CupertinoSwitch(
                    value: _isPushEnabled,
                    activeColor: AppColors.successPrimary, // Green as in design
                    onChanged: (v) => setState(() => _isPushEnabled = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
