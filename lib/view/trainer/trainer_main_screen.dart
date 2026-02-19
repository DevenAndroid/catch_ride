import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';

import 'bookings/bookings_screen.dart';
import 'explore/explore_screen.dart';
import 'inbox/inbox_screen.dart';
import 'list/list_screen.dart';
import 'menu/menu_screen.dart';
import 'package:catch_ride/view/trainer/add_select_screen.dart';

class TrainerMainScreen extends StatefulWidget {
  const TrainerMainScreen({super.key});

  @override
  State<TrainerMainScreen> createState() => _TrainerMainScreenState();
}

class _TrainerMainScreenState extends State<TrainerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ExploreScreen(),
    const BookingsScreen(),
    const ListScreen(),
    const InboxScreen(),
    const MenuScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.deepNavy,
        unselectedItemColor: AppColors.grey400,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => const AddSelectScreen(),
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                );
              },
              child: const CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.deepNavy,
                child: Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
            label: '', // Empty label for center FAB style
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Inbox',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }
}
