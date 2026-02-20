import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/trainer/inbox/chat_detail_screen.dart';
import 'package:catch_ride/controllers/user_role_controller.dart';

class BarnManagerInboxScreen extends StatelessWidget {
  const BarnManagerInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final roleController = Get.find<UserRoleController>();

    // Data / Logic Notes (Dev)
    // - All Barn Manager messages inherit trainerId automatically.
    // - BM ↔ Outside Trainer messaging is ONLY allowed from an active listing thread.
    // - UI hides 'Start New Conversation' for any unauthorized contacts.

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: Column(
        children: [
          // "Messaging as Trainer" Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.deepNavy.withOpacity(0.06),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppColors.deepNavy,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(
                    () => Text(
                      'Messaging as ${roleController.linkedTrainerName.value} (${roleController.linkedStableName.value})',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.deepNavy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Message List
          Expanded(
            child: ListView.separated(
              itemCount: 8,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                bool isUnread = index < 2;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.grey300,
                    backgroundImage: const NetworkImage(
                      'https://via.placeholder.com/150',
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'User Name ${index + 1}',
                        style: isUnread
                            ? AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              )
                            : AppTextStyles.titleMedium,
                      ),
                      Text('10:30 AM', style: AppTextStyles.bodySmall),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: Text(
                          isUnread
                              ? 'New inquiry about the horse availability...'
                              : 'Thanks for the update!',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: isUnread
                              ? AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.deepNavy,
                                  fontWeight: FontWeight.w600,
                                )
                              : AppTextStyles.bodyMedium,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.deepNavy,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '1',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    Get.to(
                      () =>
                          ChatDetailScreen(userName: 'User Name ${index + 1}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewMessageBottomSheet(context, roleController),
        backgroundColor: AppColors.deepNavy,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  void _showNewMessageBottomSheet(
    BuildContext context,
    UserRoleController roleController,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start New Conversation',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Barn Managers can only initiate messages with their associated Trainer or Vendors.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey600,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.deepNavy.withOpacity(0.1),
                  child: const Icon(Icons.person, color: AppColors.deepNavy),
                ),
                title: Text(
                  'Message Associated Trainer',
                  style: AppTextStyles.titleMedium,
                ),
                subtitle: Obx(
                  () => Text(roleController.linkedTrainerName.value),
                ),
                onTap: () {
                  Get.back();
                  Get.to(
                    () => ChatDetailScreen(
                      userName: roleController.linkedTrainerName.value,
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.deepNavy.withOpacity(0.1),
                  child: const Icon(Icons.handyman, color: AppColors.deepNavy),
                ),
                title: Text(
                  'Message a Vendor',
                  style: AppTextStyles.titleMedium,
                ),
                subtitle: const Text('Coordinate services & availability'),
                onTap: () {
                  Get.back();
                  Get.snackbar('Vendors', 'Vendor selection coming soon');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
