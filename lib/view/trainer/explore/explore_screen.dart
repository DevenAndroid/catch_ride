
import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/trainer/explore/filter_modal.dart';
import 'package:catch_ride/widgets/horse_card.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Explore'),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.mutedGold,
            labelColor: AppColors.deepNavy,
            unselectedLabelColor: AppColors.grey600,
            tabs: [
              Tab(text: 'All Horses'),
              Tab(text: 'Hunters'),
              Tab(text: 'Jumpers'),
              Tab(text: 'Equitation'),
              Tab(text: 'Vendors'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Search & Filter
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'City, Show Venue, or Zip',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.grey100,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.grey200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_month_outlined, color: AppColors.deepNavy),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => const FilterModal(),
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.deepNavy,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.filter_list, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: TabBarView(
                children: [
                  _buildHorseList(), // All Horses
                  _buildHorseList(), // Hunters
                  _buildHorseList(), // Jumpers
                  _buildHorseList(), // Equitation
                  Center(child: Text('Vendors Coming Soon')), // Vendors
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorseList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // Dummy data count
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: HorseCard(
            name: 'Thunderbolt',
            location: 'Wellington, FL',
            price: '\$45,000',
            breed: 'Warmblood',
            height: '16.2hh',
            age: '8 yrs',
            imageUrl: 'https://images.unsplash.com/photo-1553284965-0b0eb9e7f724?q=80&w=2574&auto=format&fit=crop', // Placeholder
            isTopRated: true,
          ),
        );
      },
    );
  }
}
