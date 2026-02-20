import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/features/trainer/bookings/bookings_screen.dart';
import 'package:catch_ride/view/trainer/explore/explore_screen.dart';
import 'package:catch_ride/view/barn_manager/inbox/barn_manager_inbox_screen.dart';
import 'package:catch_ride/view/barn_manager/menu/barn_manager_menu_screen.dart';
import 'package:catch_ride/view/barn_manager/manage_horses/barn_manager_horse_list_screen.dart';

class BarnManagerMainScreen extends StatefulWidget {
  const BarnManagerMainScreen({super.key});

  @override
  State<BarnManagerMainScreen> createState() => _BarnManagerMainScreenState();
}

class _BarnManagerMainScreenState extends State<BarnManagerMainScreen> {
  int _currentIndex = 0;

  // Same tabs as Trainer: Bookings, Explore, List, Inbox, Menu
  // But with reduced permissions per spec
  final List<Widget> _screens = [
    const ExploreScreen(), // Shared — browse horses & vendors
    const BookingsScreen(), // Shared — views same bookings as Trainer
    const BarnManagerHorseListScreen(), // List tab → read-only horses + edit availability
    const BarnManagerInboxScreen(), // Messages under Trainer identity
    const BarnManagerMenuScreen(), // Reduced menu options
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.deepNavy,
        unselectedItemColor: AppColors.grey400,
        showUnselectedLabels: true,
        items: [
          // Same tab labels as Trainer per spec
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
            // '+ New' repurposed: Redirects to Manage Horses/Availability
            icon: GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = 2;
                });
              },
              child: const CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.deepNavy,
                child: Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
            label: '',
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
