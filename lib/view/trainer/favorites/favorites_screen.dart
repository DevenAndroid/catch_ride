import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/horse_card.dart';
import 'package:catch_ride/widgets/vendor_card.dart';
import 'package:catch_ride/view/trainer/explore/horse_detail_screen.dart';
import 'package:catch_ride/view/trainer/book_service/vendor_public_profile_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Saved Items'),
          bottom: const TabBar(
            indicatorColor: AppColors.mutedGold,
            labelColor: AppColors.deepNavy,
            unselectedLabelColor: AppColors.grey600,
            tabs: [
              Tab(text: 'Horses'),
              Tab(text: 'Service Providers'),
            ],
          ),
        ),
        body: TabBarView(children: [_buildHorseList(), _buildVendorList()]),
      ),
    );
  }

  Widget _buildHorseList() {
    // Mock Favorites Data
    final List<Map<String, dynamic>> favoriteHorses = [
      {
        'name': 'Midnight Star',
        'location': 'Wellington, FL',
        'price': '\$65,000',
        'breed': 'Warmblood',
        'height': '17.1hh',
        'age': '9 yrs',
        'imageUrl':
            'https://images.unsplash.com/photo-1534008897995-27a23e859048?auto=format&fit=crop&q=80&w=200',
      },
      {
        'name': 'Royal Knight',
        'location': 'Ocala, FL',
        'price': '\$45,000',
        'breed': 'Thoroughbred',
        'height': '16.2hh',
        'age': '7 yrs',
        'imageUrl':
            'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?auto=format&fit=crop&q=80&w=200',
      },
    ];

    if (favoriteHorses.isEmpty) {
      return const Center(child: Text('No saved horses yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteHorses.length,
      itemBuilder: (context, index) {
        final horse = favoriteHorses[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () {
              Get.to(() => const HorseDetailScreen());
            },
            child: HorseCard(
              name: horse['name'],
              location: horse['location'],
              price: horse['price'],
              breed: horse['breed'],
              height: horse['height'],
              age: horse['age'],
              imageUrl: horse['imageUrl'],
              isTopRated: true,
            ),
          ),
        );
      },
    );
  }

  Widget _buildVendorList() {
    // Mock Vendor Favorites
    final List<Map<String, dynamic>> favoriteVendors = [
      {
        'name': 'Elite Farriers LLC',
        'services': 'Shoeing • Trimming',
        'location': 'Wellington, FL',
        'rating': 4.9,
        'isAvailable': true,
        'imageUrl':
            'https://images.unsplash.com/photo-1598974357801-cbca100e65d3?auto=format&fit=crop&q=80&w=200',
      },
    ];

    if (favoriteVendors.isEmpty) {
      return const Center(child: Text('No saved vendors yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteVendors.length,
      itemBuilder: (context, index) {
        final vendor = favoriteVendors[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: VendorCard(
            name: vendor['name'],
            services: vendor['services'],
            location: vendor['location'],
            rating: vendor['rating'],
            isAvailable: vendor['isAvailable'],
            imageUrl: vendor['imageUrl'],
            onTap: () {
              Get.to(() => const VendorPublicProfileScreen());
            },
          ),
        );
      },
    );
  }
}
