import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/horse_card.dart';
import 'package:catch_ride/view/trainer/inbox/chat_detail_screen.dart';
import 'package:catch_ride/view/trainer/list/list_screen.dart';

class TrainerProfileScreen extends StatelessWidget {
  final bool isVisitingOwnProfile;

  const TrainerProfileScreen({super.key, this.isVisitingOwnProfile = false});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final String trainerName = 'John Smith';
    final String barnName = 'Wellington Stables';
    final List<String> locations = [
      'Wellington, FL',
      'Ocala, FL',
      'Lexington, KY',
    ];
    final int yearsExperience = 15;
    final int activeListings = 4;
    final List<String> specialties = ['Hunters', 'Equitation', 'Sales'];
    final List<String> showCircuits = [
      'WEF (Winter Equestrian Festival)',
      'WEC Ocala',
      'Tryon Summer',
    ];
    final String bannerImage =
        'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?auto=format&fit=crop&q=80&w=800';
    final String profileImage = 'https://via.placeholder.com/150';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.deepNavy),
            onPressed: () => Get.back(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner & Profile
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(bannerImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  left: 24,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(profileImage),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80), // Space for profile image
            // Trainer Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trainerName,
                    style: AppTextStyles.headlineMedium.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.house, size: 16, color: AppColors.grey600),
                      const SizedBox(width: 4),
                      Text(
                        barnName,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Locations (Stacked)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: locations
                        .map(
                          (loc) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: AppColors.grey500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  loc,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.grey600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 24),

                  // Stats
                  Row(
                    children: [
                      _buildStatItem('Years Exp.', '$yearsExperience'),
                      const SizedBox(width: 24),
                      _buildStatItem('Active Listings', '$activeListings'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Specialties
                  Text('Specialties', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: specialties
                        .map(
                          (s) => Chip(
                            label: Text(s),
                            backgroundColor: AppColors.grey100,
                            labelStyle: TextStyle(color: AppColors.deepNavy),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 24),

                  // Show Circuits
                  Text('Show Circuits', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: showCircuits.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey300),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              showCircuits[index],
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Message CTA
                  if (!isVisitingOwnProfile) ...[
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Message',
                        onPressed: () {
                          Get.to(() => ChatDetailScreen(userName: trainerName));
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 24),

                  // Horses Available Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Horses',
                        style: AppTextStyles.headlineMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to filtered list
                          Get.to(() => const ListScreen()); // Placeholder
                        },
                        child: Text(
                          'View all',
                          style: TextStyle(color: AppColors.mutedGold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Horse List Preview
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          // Navigate to Horse Detail
                          Get.snackbar('Coming Soon', 'Horse Detail Screen');
                        },
                        child: HorseCard(
                          name: 'Thunderbolt',
                          location: 'Wellington, FL',
                          price: '\$45,000',
                          breed: 'Warmblood',
                          height: '16.2hh',
                          age: '8 yrs',
                          imageUrl:
                              'https://images.unsplash.com/photo-1553284965-0b0eb9e7f724?q=80&w=2574&auto=format&fit=crop',
                          isTopRated: index == 0,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTextStyles.headlineMedium.copyWith(fontSize: 20)),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
        ),
      ],
    );
  }
}
