import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/profile_controller.dart';

class BarnManagerProfileView extends StatelessWidget {
  const BarnManagerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Banner
                const CommonImageView(
                  url: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                  height: 240,
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

                // Profile Image overlapping banner
                Positioned(
                  bottom: -50,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CommonImageView(
                      url: controller.avatar.isNotEmpty ? controller.avatar : 'https://images.unsplash.com/photo-1531123897727-8f129e16fd3c?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
                      height: 100,
                      width: 100,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 60),

            // Profile Info (Name, Phone, Email)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => CommonText(
                    controller.fullName.isNotEmpty ? controller.fullName : 'Lisa James',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF101828),
                  )),
                  const SizedBox(height: 4),
                  Obx(() => CommonText(
                    controller.phone.isNotEmpty ? controller.phone : '+1 6587 4385 244',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF667085),
                  )),
                  const SizedBox(height: 2),
                  Obx(() => CommonText(
                    controller.user.value?.email ?? 'lisa@example.com',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF667085),
                  )),
                  
                  const SizedBox(height: 20),
                  
                  // Bio
                  Obx(() => CommonText(
                    controller.bio.isNotEmpty 
                      ? controller.bio 
                      : "I'm Alex, a passionate hair stylist with over 10 years of experience in transforming looks and boosting confidence. My journey began in a small town, and since then, I've honed my skills in various styles, from classic cuts to trendy colors.",
                    fontSize: 15,
                    color: const Color(0xFF475467),
                    height: 1.6,
                  )),
                  
                  const SizedBox(height: 30),
                  
                  // Associate Trainer Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00083B), // Dark navy blue from mockup
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CommonText(
                          'Associate trainer',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const CommonImageView(
                                url: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
                                height: 75,
                                width: 75,
                                shape: BoxShape.circle,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const CommonText(
                                      'John Snow',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF101828),
                                    ),
                                    const SizedBox(height: 4),
                                    const CommonText(
                                      'Willow Creek Stables',
                                      fontSize: 15,
                                      color: Color(0xFF667085),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: const [
                                        Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF2E90FA)),
                                        SizedBox(width: 4),
                                        Expanded(
                                          child: CommonText(
                                            "Ocklawaha, USA, United States",
                                            fontSize: 13,
                                            color: Color(0xFF2E90FA),
                                            fontWeight: FontWeight.w500,
                                            decoration: TextDecoration.underline,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
}
