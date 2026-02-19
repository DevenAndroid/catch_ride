import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/trainer/inbox/chat_detail_screen.dart';

class VendorInboxScreen extends StatelessWidget {
  const VendorInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        automaticallyImplyLeading: false,
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Column(
        children: [
          // Quick Filters
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildFilterChip('All', true),
                _buildFilterChip('Unread', false),
                _buildFilterChip('Bookings', false),
                _buildFilterChip('General', false),
              ],
            ),
          ),

          // Message List
          Expanded(
            child: ListView.separated(
              itemCount: 6,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                bool isUnread = index < 2;
                bool isBookingRelated = index < 3;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.grey300,
                        child: Text(
                          _clientInitials(index),
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.deepNavy,
                          ),
                        ),
                      ),
                      if (isBookingRelated)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.mutedGold,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.handyman,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _clientName(index),
                        style: isUnread
                            ? AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              )
                            : AppTextStyles.titleMedium,
                      ),
                      Text(
                        _messageTime(index),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isUnread
                              ? AppColors.deepNavy
                              : AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isBookingRelated)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.mutedGold.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Booking Inquiry',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.mutedGold,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _messagePreview(index),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: isUnread
                                  ? AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.deepNavy,
                                      fontWeight: FontWeight.w600,
                                    )
                                  : AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.grey600,
                                    ),
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
                                '${index + 1}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    Get.to(
                      () => ChatDetailScreen(userName: _clientName(index)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {},
        selectedColor: AppColors.deepNavy,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.deepNavy,
          fontWeight: FontWeight.w500,
        ),
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  String _clientInitials(int index) {
    const initials = ['SW', 'EJ', 'MD', 'LC', 'RB', 'TN'];
    return initials[index % initials.length];
  }

  String _clientName(int index) {
    const names = [
      'Sarah Williams',
      'Emily Johnson',
      'Michael Davis',
      'Lisa Chen',
      'Rachel Brooks',
      'Tom Nelson',
    ];
    return names[index % names.length];
  }

  String _messageTime(int index) {
    const times = [
      'Just now',
      '2:15 PM',
      '11:30 AM',
      'Yesterday',
      'Feb 17',
      'Feb 15',
    ];
    return times[index % times.length];
  }

  String _messagePreview(int index) {
    const previews = [
      'Hi, are you available for grooming on March 5th?',
      'Can you do braiding for two horses at WEF?',
      'Great, I\'ll confirm the booking then!',
      'Thanks for the amazing work yesterday!',
      'Do you travel to Ocala for shows?',
      'What\'s your rate for a full show weekend?',
    ];
    return previews[index % previews.length];
  }
}
