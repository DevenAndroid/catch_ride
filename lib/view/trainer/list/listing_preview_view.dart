import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/add_new_listing_controller.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListingPreviewView extends StatelessWidget {
  const ListingPreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddNewListingController>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Horse Detail',
          fontSize: AppTextSizes.size18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Active Listing Toggle
            Obx(
              () => Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        CommonText(
                          'Active Listing',
                          fontWeight: FontWeight.bold,
                          fontSize: AppTextSizes.size14,
                        ),
                        SizedBox(height: 4),
                        CommonText(
                          'Make listing visible to others',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    Switch(
                      value: controller.activeStatus.value,
                      onChanged: (val) => controller.activeStatus.value = val,
                      activeColor: const Color(0xFF047857),
                    ),
                  ],
                ),
              ),
            ),
            // Trainer Info
            ListTile(
              leading: const CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=12',
                ),
              ),
              title: const CommonText(
                'John Snow',
                fontWeight: FontWeight.bold,
                fontSize: AppTextSizes.size16,
              ),
              subtitle: const CommonText(
                'Professional Horse Trainer',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              trailing: const Icon(Icons.more_vert),
            ),
            // Image
            Stack(
              children: [
                CommonImageView(
                  url:
                      'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?auto=format&fit=crop&q=80&w=1000',
                  height: 250,
                  width: double.infinity,
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const CommonText(
                      '1 / 12',
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildChip('For sale'),
                      const SizedBox(width: 8),
                      _buildChip('Weekly Lease'),
                      const Spacer(),
                      const Icon(
                        Icons.share_outlined,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.bookmark_border,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CommonText(
                    controller.listingTitleController.text.isEmpty
                        ? 'Demo horse - Young Developing Hunter'
                        : controller.listingTitleController.text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  CommonText(
                    controller.descriptionController.text.isEmpty
                        ? 'An ideal small pony and great for a Child An ideal small pony and great for a ChildAn ideal small pony and great for a Child An ideal small pony and great for a Child.'
                        : controller.descriptionController.text,
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      CommonText(
                        'Ocklawaha, USA, United States',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // USEF Number
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFFF9FAFB),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CommonText(
                    'Horse USEF number',
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  CommonText(
                    controller.usefNumberController.text.isEmpty
                        ? '5w3bnd67'
                        : controller.usefNumberController.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ],
              ),
            ),
            // Details
            _buildSectionHeader('Details'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Horse name',
                    controller.horseNameController.text.isEmpty
                        ? 'Thunderbolt'
                        : controller.horseNameController.text,
                  ),
                  _buildDetailRow(
                    'Age',
                    controller.ageController.text.isEmpty
                        ? '14 Years'
                        : controller.ageController.text,
                  ),
                  _buildDetailRow(
                    'Height',
                    controller.heightController.text.isEmpty
                        ? '16.2hh'
                        : controller.heightController.text,
                  ),
                  _buildDetailRow(
                    'Breed',
                    controller.breedController.text.isEmpty
                        ? 'Thoroughbred'
                        : controller.breedController.text,
                  ),
                  _buildDetailRow(
                    'Color',
                    controller.colorController.text.isEmpty
                        ? 'Brown'
                        : controller.colorController.text,
                  ),
                  _buildDetailRow(
                    'Discipline',
                    controller.disciplineController.text.isEmpty
                        ? '\$100'
                        : controller.disciplineController.text,
                  ),
                ],
              ),
            ),
            // Availability
            _buildSectionHeader('Availability'),
            Obx(
              () => Column(
                children: controller.availabilityEntries
                    .map((entry) => _buildAvailabilityCard(entry))
                    .toList(),
              ),
            ),
            // Tags
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: [
                  _buildTagCard(
                    'Program Tag',
                    controller.selectedProgramTags.isNotEmpty
                        ? controller.selectedProgramTags.first
                        : 'Big Equitation',
                  ),
                  _buildTagCard(
                    'Opportunity Tag',
                    controller.selectedOpportunityTags.isNotEmpty
                        ? controller.selectedOpportunityTags.first
                        : 'Firesale',
                  ),
                  _buildTagCard(
                    'Experience',
                    controller.selectedExperienceTags.isNotEmpty
                        ? controller.selectedExperienceTags.first
                        : 'Division Pony',
                  ),
                  _buildTagCard(
                    'Experience',
                    controller.selectedPersonalityTags.isNotEmpty
                        ? controller.selectedPersonalityTags.first
                        : 'Brave / Bold',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CommonText(label, fontSize: 12, color: AppColors.textSecondary),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: CommonText(title, fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: CommonText(
              label,
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const CommonText(' : ', fontWeight: FontWeight.bold, fontSize: 14),
          Expanded(
            child: CommonText(value, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard(AvailabilityEntry entry) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFF9FAFB)),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            'Location ${entry.id}',
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              CommonText(
                entry.cityStateController.text.isEmpty
                    ? 'Ocklawaha, USA, United States'
                    : entry.cityStateController.text,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              CommonText(
                '${entry.startDateController.text.isEmpty ? '05 Feb' : entry.startDateController.text} - ${entry.endDateController.text.isEmpty ? '10 Feb 2026' : entry.endDateController.text}',
                fontSize: 12,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CommonText(title, fontSize: 10, color: AppColors.textSecondary),
          const SizedBox(height: 4),
          CommonText(value, fontSize: 12, fontWeight: FontWeight.bold,maxLines: 1,),
        ],
      ),
    );
  }
}
