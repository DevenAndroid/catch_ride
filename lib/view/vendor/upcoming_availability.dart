import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/upcoming_availability_controller.dart';
import 'package:catch_ride/models/vendor_availability_model.dart';
import 'package:catch_ride/view/vendor/braiding/availability/braiding_availability_card.dart';
import 'package:catch_ride/view/vendor/clipping/availability/clipping_availability_block_card.dart';
import 'package:catch_ride/view/vendor/farrier/availability/farrier_availability_block_card.dart';
import 'package:catch_ride/view/vendor/bodywork/availability/bodywork_availability_block_card.dart';
import 'package:catch_ride/view/vendor/shipping/availability/shipping_trip_card.dart';
import 'package:catch_ride/models/trip_model.dart';
import 'package:catch_ride/view/vendor/groom/availability/grooming_availability_card.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/controllers/vendor/vendor_availability_controller.dart';
import 'package:catch_ride/view/vendor/groom/availability/add_availability_block_view.dart';
import 'package:catch_ride/view/vendor/clipping/availability/add_clipping_availability_view.dart';
import 'package:catch_ride/view/vendor/farrier/availability/add_farrier_availability_view.dart';
import 'package:catch_ride/view/vendor/bodywork/availability/bodywork_add_availability.dart';
import 'package:catch_ride/view/vendor/braiding/availability/braiding_add_availability.dart';
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
            itemCount: controller.combinedList.length + 1,
            itemBuilder: (context, index) {
              if (index < controller.combinedList.length) {
                final item = controller.combinedList[index];
                
                if (item is TripModel) {
                  return ShippingTripCard(trip: item);
                }

                final b = item as VendorAvailabilityModel;
                final serviceTypes = b.serviceTypes;

                final authController = Get.find<AuthController>();
                final isOwner = b.vendorId == authController.currentUser.value?.vendorProfileId;

                final onEdit = isOwner ? () {
                  final type = serviceTypes.firstOrNull ?? 'Grooming';
                  if (type == 'Farrier') {
                    Get.to(() => const AddFarrierAvailabilityView(), arguments: {'block': b});
                  } else if (type == 'Clipping') {
                    Get.to(() => const AddClippingAvailabilityView(), arguments: {'block': b});
                  } else if (type == 'Braiding') {
                    Get.to(() => const BraidingAddAvailabilityView(), arguments: {'block': b});
                  } else if (type == 'Bodywork') {
                    Get.to(() => const BodyworkAddAvailabilityView(), arguments: {'block': b});
                  } else {
                    Get.to(() => const AddAvailabilityBlockView(), arguments: {
                      'categoryIndex': 0,
                      'block': b
                    });
                  }
                } : null;

                final onDelete = isOwner ? () {
                  if (b.id != null) {
                    final availabilityController = Get.isRegistered<VendorAvailabilityController>() 
                        ? Get.find<VendorAvailabilityController>() 
                        : Get.put(VendorAvailabilityController());
                    availabilityController.deleteAvailabilityBlock(b.id!);
                  }
                } : null;

                if (b.serviceTypes.contains('Braiding')) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: BraidingAvailabilityCard(availability: b, onEdit: onEdit, onDelete: onDelete),
                  );
                }
                if (b.serviceTypes.contains('Clipping')) {
                  return ClippingAvailabilityBlockCard(block: b, onEdit: onEdit, onDelete: onDelete);
                }
                if (b.serviceTypes.contains('Farrier')) {
                  return FarrierAvailabilityBlockCard(block: b, onEdit: onEdit, onDelete: onDelete);
                }
                if (b.serviceTypes.contains('Bodywork')) {
                  return BodyworkAvailabilityBlockCard(block: b, onEdit: onEdit, onDelete: onDelete);
                }
                return GroomingAvailabilityCard(availability: b, onEdit: onEdit, onDelete: onDelete);
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

