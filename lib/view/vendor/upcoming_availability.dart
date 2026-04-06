import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/upcoming_availability_controller.dart';
import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpcomingAvailability extends StatefulWidget {
  const UpcomingAvailability({super.key});

  @override
  State<UpcomingAvailability> createState() => _UpcomingAvailabilityState();
}

class _UpcomingAvailabilityState extends State<UpcomingAvailability> {
  final controller = Get.put(UpcomingAvailabilityController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Upcoming Availability',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.availabilityList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                const CommonText(
                  'No upcoming availability found.',
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAvailability,
          child: ListView.builder(
            controller: controller.scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: controller.availabilityList.length + 1,
            itemBuilder: (context, index) {
              if (index < controller.availabilityList.length) {
                return _buildAvailabilityCard(controller.availabilityList[index]);
              } else {
                return controller.hasMore.value
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : const SizedBox(height: 40);
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildAvailabilityCard(VendorAvailabilityModel b) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
       borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.secondary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        b.dateDisplay,
                        color: Colors.white,
                        fontSize: AppTextSizes.size16,
                        fontWeight: FontWeight.bold,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: CommonText(
                              b.locationDisplay,
                              color: Colors.white70,
                              fontSize: AppTextSizes.size12,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, color: Colors.white),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: b.serviceTypes.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: CommonText(t, fontSize: AppTextSizes.size12, color: AppColors.textPrimary),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.catching_pokemon, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    CommonText(
                      'Max ${b.maxBookings} Horses',
                      fontSize: AppTextSizes.size12,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                if (b.notes != null && b.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.description_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: CommonText(
                          b.notes!,
                          fontSize: AppTextSizes.size12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
