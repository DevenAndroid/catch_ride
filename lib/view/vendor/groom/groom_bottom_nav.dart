import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/view/vendor/groom/booking/booking_view.dart';
import 'package:catch_ride/view/vendor/groom/availability/availability_view.dart';
import 'package:catch_ride/view/vendor/groom/chat/groom_chat_view.dart';
import 'package:catch_ride/view/vendor/groom/menu/menu_view.dart';
import 'package:catch_ride/view/vendor/shipping/trip/shipping_trip_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'profile/groom_view_profile.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/widgets/common_image_view.dart';

class GroomBottomNav extends StatefulWidget {
  final int initialIndex;
  const GroomBottomNav({super.key, this.initialIndex = 0});

  @override
  State<GroomBottomNav> createState() => _GroomBottomNavState();
}

class _GroomBottomNavState extends State<GroomBottomNav> {
  late int _selectedIndex;
  final AuthController _authController = Get.find<AuthController>();

  late final List<Widget> _views;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    
    final user = _authController.currentUser.value;
    final isShipping = user?.vendorServices.contains('Shipping') ?? false;

    _views = [
      const GroomViewProfile(),
      const BookingView(),
      isShipping ? const ShippingTripView() : const AvailabilityView(),
      GroomChatView(),
      const MenuView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final user = _authController.currentUser.value;
    final isShipping = user?.vendorServices.any((s) => s.toLowerCase() == 'shipping') ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _views[_selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: SafeArea(
          child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, 'Profile', Icons.person, isAvatar: true),
              _buildNavItem(1, 'Booking', "assets/icons/booking.svg"),
              _buildNavItem(2, isShipping ? 'Trips' : 'Availability', isShipping ? "assets/icons/route.svg" : "assets/icons/availability.svg"),
              _buildNavItem(3, 'Inbox', "assets/icons/message.svg"),
              _buildNavItem(4, 'Menu', "assets/icons/menu_bottom.svg"),
            ],
          )),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, dynamic icon, {bool isAvatar = false}) {
    final isSelected = _selectedIndex == index;
    final user = _authController.currentUser.value;
    final avatarUrl = user?.displayAvatar ?? '';

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (index == 3)
              Obx(() {
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
                  child: SvgPicture.asset(
                    icon as String,
                    width: 24,
                    height: 24,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                );
              })
            else if (isAvatar && avatarUrl.isNotEmpty)
              ClipOval(
                child: CommonImageView(
                  url: avatarUrl,
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              )
            else if (icon is IconData)
              Icon(
                icon,
                size: 24,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              )
            else if (icon is String && icon.isNotEmpty)
              SvgPicture.asset(
                icon,
                width: 24,
                height: 24,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              )
            else
              const SizedBox(height: 24, width: 24),
            const SizedBox(height: 4),
            CommonText(
              label,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
