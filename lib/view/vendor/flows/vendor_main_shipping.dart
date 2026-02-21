import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/view/vendor/profile/flows/profile_page_shipping.dart';
import 'package:catch_ride/view/vendor/bookings/flows/shipping_booking_screens.dart';
import 'package:catch_ride/view/vendor/availability/flows/availability_shipping.dart';
import 'package:catch_ride/view/vendor/inbox/vendor_inbox_screen.dart';
import 'package:catch_ride/view/vendor/menu/flows/menu_shipping.dart';

class VendorMainShippingScreen extends StatefulWidget {
  const VendorMainShippingScreen({super.key});

  @override
  State<VendorMainShippingScreen> createState() =>
      _VendorMainShippingScreenState();
}

class _VendorMainShippingScreenState extends State<VendorMainShippingScreen> {
  // Shipping defaults to Availability (Index 2)
  int _currentIndex = 2;

  final List<Widget> _screens = [
    const ProfilePageShippingScreen(), // 0. Profile
    const BookingListShippingScreen(), // 1. Bookings
    const AvailabilityShippingScreen(), // 2. Availability (Default Landing)
    const VendorInboxScreen(), // 3. Inbox
    const MenuShippingScreen(), // 4. Menu
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.deepNavy,
        unselectedItemColor: AppColors.grey400,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Availability',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }
}
