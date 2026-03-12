import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/models/horse_model.dart';
import 'package:catch_ride/view/trainer/home/trainer_horse_detail_view.dart';
import 'package:catch_ride/view/trainer/settings/view_all_horses_view.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/profile_controller.dart';

class TrainerProfileView extends StatelessWidget {
  TrainerProfileView({super.key});

  final ProfileController _controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final profile = _controller.user.value;
        if (_controller.isLoading.value && profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (profile == null) {
          return const Center(child: CommonText('Profile not found'));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CommonImageView(
                    url: _controller.coverImage,
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  
                  // Gradient Overlay for Banner
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Back Button
                  Positioned(
                    top: 50,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
                      ),
                    ),
                  ),
                  
                  // More Button
                  Positioned(
                    top: 50,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.more_vert, size: 20, color: Colors.black),
                    ),
                  ),

                  // Profile Image
                  Positioned(
                    bottom: -60,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
                        ]
                      ),
                      child: CommonImageView(
                        url: _controller.avatar,
                        height: 110,
                        width: 110,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 70),

              // Profile Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      _controller.fullName,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(height: 4),
                    
                    Row(
                      children: [
                        CommonText(
                          _controller.specialization,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        if (_controller.yearsExperience > 0) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.0),
                            child: CommonText("·", color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                          ),
                          CommonText(
                            '${_controller.yearsExperience} Years',
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ]
                      ],
                    ),
                    
                    if (_controller.bio.isNotEmpty)
                      CommonText(
                        _controller.bio,
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    
                    if ((profile.instagram?.isNotEmpty ?? false) || (profile.facebook?.isNotEmpty ?? false) || (profile.website?.isNotEmpty ?? false))
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Row(
                          children: [
                            if (profile.instagram?.isNotEmpty ?? false)
                              Expanded(child: _buildSocialButton('Instagram', Icons.camera_alt_outlined, Colors.pink)),
                            if (profile.facebook?.isNotEmpty ?? false)
                              ...[
                                const SizedBox(width: 8),
                                Expanded(child: _buildSocialButton('Facebook', Icons.facebook, Colors.blue)),
                              ],
                            if (profile.website?.isNotEmpty ?? false)
                              ...[
                                const SizedBox(width: 8),
                                Expanded(child: _buildSocialButton('Website', Icons.link, Colors.black54)),
                              ],
                          ],
                        ),
                      ),
                    
                    if (_controller.location.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: _buildSectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                profile.barnName?.isNotEmpty ?? false ? 'Barn - ${profile.barnName}' : 'Location',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Wrap(
                                      children: [
                                        CommonText(_controller.location, fontSize: 13, color: AppColors.textSecondary),
                                        if (profile.location2?.isNotEmpty ?? false) ...[
                                          const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                                            child: CommonText("|", color: Colors.grey),
                                          ),
                                          CommonText(profile.location2!, fontSize: 13, color: AppColors.textSecondary),
                                        ]
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Dynamic Tag Sections
                    ..._controller.groupedTrainerTags.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(entry.key, fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 10,
                              children: entry.value.map((tagName) => _buildTagChip(tagName)).toList(),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    // Legacy Show Circuits (If any)
                    if (_controller.selectedHorseShows.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CommonText('Horse Shows & Circuits', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 10,
                              children: _controller.selectedHorseShows.map((tagName) => _buildTagChip(tagName)).toList(),
                            ),
                          ],
                        ),
                      ),

                    // Available Horses Section
                    Obx(() {
                      if (_controller.trainerHorses.isEmpty) return const SizedBox.shrink();
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CommonText(
                                'Available Horses (${_controller.trainerHorses.length})',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              TextButton(
                                onPressed: () => Get.to(() => const ViewAllHorsesView()), 
                                child: const CommonText('View all', color: AppColors.primary, fontWeight: FontWeight.bold)
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ..._controller.trainerHorses.map((horse) => _buildHorseCard(horse)).toList(),
                        ],
                      );
                    }),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTagChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FF),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFFE8EEFF)),
      ),
      child: CommonText(
        label, 
        fontSize: 13, 
        fontWeight: FontWeight.w600, 
        color: const Color(0xFF000B48)
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          CommonText(label, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildHorseCard(HorseModel horse) {
    return GestureDetector(
      onTap: () => Get.to(() => TrainerHorseDetailView(horse: horse)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CommonImageView(
                url: horse.photo ?? horse.images.firstOrNull,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(horse.name ?? 'Unknown', fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  const SizedBox(height: 4),
                  CommonText("${horse.age} year old ${horse.breed ?? 'Horse'}", fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  const SizedBox(height: 8),
                  CommonText(
                    horse.description ?? '',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
