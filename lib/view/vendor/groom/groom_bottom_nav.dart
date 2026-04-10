import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/view/vendor/groom/booking/booking_view.dart';
import 'package:catch_ride/view/vendor/groom/availability/availability_view.dart';
import 'package:catch_ride/view/vendor/groom/chat/groom_chat_view.dart';
import 'package:catch_ride/view/vendor/groom/menu/menu_view.dart';
import 'package:catch_ride/view/vendor/shipping/shipping_trip_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'profile/groom_view_profile.dart';

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
              _buildNavItem(1, 'Booking', Icons.calendar_today_outlined),
              _buildNavItem(2, isShipping ? 'Trips' : 'Availability', isShipping ? Icons.route_outlined : Icons.access_time),
              _buildNavItem(3, 'Inbox', Icons.chat_bubble_outline),
              _buildNavItem(4, 'Menu', Icons.menu),
            ],
          )),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon, {bool isAvatar = false}) {
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
            if (isAvatar && avatarUrl.isNotEmpty)
               Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(avatarUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Icon(
                icon,
                size: 24,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
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
