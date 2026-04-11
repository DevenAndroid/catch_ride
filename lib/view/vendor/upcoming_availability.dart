import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/upcoming_availability_controller.dart';
import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/view/vendor/braiding/availability/braiding_availability_card.dart';
import 'package:catch_ride/view/vendor/clipping/availability/clipping_availability_block_card.dart';
import 'package:catch_ride/view/vendor/farrier/availability/farrier_availability_block_card.dart';
import 'package:catch_ride/view/vendor/bodywork/availability/bodywork_availability_block_card.dart';
import 'package:catch_ride/view/vendor/groom/availability/grooming_availability_card.dart';
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
                final b = controller.availabilityList[index];
                if (b.serviceTypes.contains('Braiding')) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: BraidingAvailabilityCard(availability: b),
                  );
                }
                if (b.serviceTypes.contains('Clipping')) {
                  return ClippingAvailabilityBlockCard(block: b);
                }
                if (b.serviceTypes.contains('Farrier')) {
                  return FarrierAvailabilityBlockCard(block: b);
                }
                if (b.serviceTypes.contains('Bodywork')) {
                  return BodyworkAvailabilityBlockCard(block: b);
                }
                return GroomingAvailabilityCard(availability: b);
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

  }

