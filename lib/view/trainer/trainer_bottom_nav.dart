import 'package:catch_ride/controllers/booking_controller.dart';
import 'package:catch_ride/controllers/horse_controller.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/controllers/explore_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/view/trainer/bookings/trainer_bookings_view.dart';
import 'package:catch_ride/view/trainer/home/trainer_explore_view.dart';
import 'package:catch_ride/view/trainer/chats/chats_view.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/view/trainer/settings/settings_view.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'list/horse_listing_view.dart';

class TrainerBottomNav extends StatefulWidget {
  final int initialIndex;

  const TrainerBottomNav({
    super.key,
    this.initialIndex = 1, // Default to Explore (index 1)
  });

  @override
  State<TrainerBottomNav> createState() => _TrainerBottomNavState();
}

class _TrainerBottomNavState extends State<TrainerBottomNav> {
  late int _selectedIndex;

  // Views aligned with the UI order: Bookings, Explore, List, Inbox, Menu
  final List<Widget> _views = [
    const TrainerBookingsView(),
    const TrainerExploreView(),
    const HorseListingView(),
    const TrainerChatsView(),
    const SettingsView(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    
    // Initialize core controllers here once, not in build
    Get.put(ProfileController());
    Get.put(HorseController());
    Get.put(BookingController());
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      if (Get.isRegistered<ExploreController>()) {
        final exploreController = Get.find<ExploreController>();
        exploreController.clearAllFilters();
        exploreController.fetchHorses();
      }
    } else if (index == 2) {
      if (Get.isRegistered<HorseController>() && Get.isRegistered<ProfileController>()) {
        final horseController = Get.find<HorseController>();
        final profileController = Get.find<ProfileController>();
        
        final trainerId = profileController.trainerId;
        final userId = profileController.id;
        
        if (trainerId.isNotEmpty) {
          horseController.fetchHorses(refresh: true, trainerId: trainerId);
        } else if (userId.isNotEmpty) {
          horseController.fetchHorses(refresh: true, ownerId: userId);
        }
      }
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _views,
      ),


      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, 'Bookings', LucideIcons.calendarDays),
              _buildNavItem(1, 'Explore', LucideIcons.search),
              _buildNavItem(2, 'List', LucideIcons.circlePlus),
              _buildNavItem(3, 'Inbox', LucideIcons.messageCircleMore),
              _buildNavItem(4, 'Menu', LucideIcons.menu),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            index == 3 
              ? Obx(() {
                  final chatController = Get.find<ChatController>();
                  final unreadCount = chatController.totalUnreadCount;
                  return Badge(
                    label: CommonText(
                      '$unreadCount',
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    isLabelVisible: unreadCount > 0,
                    backgroundColor: const Color(0xFFB42318),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      size: 26,
                    ),
                  );
                })
              : Icon(
                  icon,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  size: 26,
                ),
            const SizedBox(height: 4),
            CommonText(
              label,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
