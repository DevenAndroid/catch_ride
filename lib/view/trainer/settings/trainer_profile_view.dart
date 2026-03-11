import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrainerProfileView extends StatelessWidget {
  const TrainerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Banner
                const CommonImageView(
                  url: 'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
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
                    ),
                    child: const CommonImageView(
                      url: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
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
                  const CommonText(
                    'John Snow',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  const CommonText(
                    '4 years',
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  const CommonText(
                    "I'm Alex, a passionate hair stylist with over 10 years of experience in transforming looks and boosting confidence. My journey began in a small town, and since then, I've honed my skills in various styles, from classic cuts to trendy colors.",
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Social Media
                  Row(
                    children: [
                      Expanded(child: _buildSocialButton('Instagram', Icons.camera_alt_outlined, Colors.pink)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildSocialButton('Facebook', Icons.facebook, Colors.blue)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildSocialButton('Website', Icons.link, Colors.grey)),
                    ],
                  ),
                  
                  const SizedBox(height: 24),

                  // Barn Section
                  _buildSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CommonText(
                          'Barn - Westbridge Equestrian',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: const [
                            Icon(Icons.location_on_outlined, size: 18, color: AppColors.textSecondary),
                            SizedBox(width: 4),
                            CommonText(
                              "Ocala, FL",
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 16),
                            Icon(Icons.location_on_outlined, size: 18, color: AppColors.textSecondary),
                            SizedBox(width: 4),
                            CommonText(
                              "Wellington, FL",
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Program Tags & Show Circuits (Two Column)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildSectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              CommonText('Program Tags', fontSize: 16, fontWeight: FontWeight.bold),
                              SizedBox(height: 8),
                              CommonText('Big Equitation', fontSize: 13, color: AppColors.textSecondary),
                              SizedBox(height: 4),
                              CommonText('Prospect', fontSize: 13, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              CommonText('Show Circuits', fontSize: 16, fontWeight: FontWeight.bold),
                              SizedBox(height: 8),
                              CommonText('WEC Ocala', fontSize: 13, color: AppColors.textSecondary),
                              SizedBox(height: 4),
                              CommonText('Tryon', fontSize: 13, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Available Horses
                  const CommonText(
                    'Available Horses',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildHorseCard(
                    name: 'Whirlwind',
                    desc: "8-year-old Warmblood Gelding",
                    subDesc: "An ideal small pony and great for a Child An ideal small pony and great for a Child",
                    imageUrl: 'https://images.unsplash.com/photo-1534073828943-f801091bb18c?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
                  ),
                  _buildHorseCard(
                    name: 'Midnight Star',
                    desc: "10-year-old Warmblood Gelding",
                    subDesc: "An ideal small pony and great for a Child An ideal small pony and great for a Child",
                    imageUrl: 'https://images.unsplash.com/photo-1533167649158-6d508895b680?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
                  ),
                  _buildHorseCard(
                    name: 'Golden Dream',
                    desc: "12-year-old Warmblood Gelding",
                    subDesc: "An ideal small pony and great for a Child An ideal small pony and great for a Child",
                    imageUrl: 'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
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

  Widget _buildHorseCard({required String name, required String desc, required String subDesc, required String imageUrl}) {
    return Container(
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
              url: imageUrl,
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
                CommonText(name, fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                const SizedBox(height: 4),
                CommonText(desc, fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                const SizedBox(height: 8),
                CommonText(
                  subDesc,
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
    );
  }
}
