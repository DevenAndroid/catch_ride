import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PastServicesView extends StatelessWidget {
  const PastServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF344054), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Past services',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF344054),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFEAECF0), height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildServiceCard(
            horseName: 'Golden Hour',
            trainer: 'Emily Johnson',
            location: 'Cypress, CA, United States',
            date: '20 Mar 2026',
            imageUrl: 'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
          ),
          const SizedBox(height: 12),
          _buildServiceCard(
            horseName: 'Valentino Z',
            trainer: 'Mark Lee',
            location: 'Tampa, FL, United States',
            date: '07 Apr 2026',
            imageUrl: 'https://images.unsplash.com/photo-1598974357801-cbca100e6563?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
          ),
          const SizedBox(height: 12),
          _buildServiceCard(
            horseName: 'Valentino Z',
            trainer: 'Mark Lee',
            location: 'Tampa, FL, United States',
            date: '07 Apr 2026',
            imageUrl: 'https://images.unsplash.com/photo-1598974357801-cbca100e6563?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required String horseName,
    required String trainer,
    required String location,
    required String date,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Completed badge
          Stack(
            children: [
              CommonImageView(
                url: imageUrl,
                height: 90,
                width: 100,
                radius: 12,
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const CommonText(
                    'Completed',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF12B76A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CommonText(
                        horseName,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF101828),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const CommonText(
                        'Trial',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF667085),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                CommonText(
                  'Trainer : $trainer',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF475467),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF98A2B3)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: CommonText(
                        location,
                        fontSize: 12,
                        color: const Color(0xFF667085),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF98A2B3)),
                    const SizedBox(width: 6),
                    CommonText(
                      date,
                      fontSize: 12,
                      color: const Color(0xFF667085),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
