import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/shipping/shipping_trip_controller.dart';
import 'package:catch_ride/view/vendor/shipping/add_trip_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ShippingTripView extends StatelessWidget {
  const ShippingTripView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShippingTripController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const CommonText(
          'My Trips',
          fontSize: AppTextSizes.size24,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => Get.to(() => const AddTripView()),
              icon: const Icon(Icons.add, size: 20, color: Colors.white),
              label: const CommonText(
                'Add',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.trips.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.trips.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.fetchTrips(),
            child: ListView(
              children: [
                SizedBox(height: Get.height * 0.2),
                const Center(
                  child: CommonText(
                    'No trips found',
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchTrips(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            itemCount: controller.trips.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CommonText(
                    'Manage and monitor your upcoming trips.',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                );
              }

              final trip = controller.trips[index - 1];
              return _buildTripCard(
                origin: trip.origin ?? 'N/A',
                destinations: [trip.destination ?? 'N/A'],
                status: trip.status,
                statusColor: controller.getStatusColor(trip.status),
                intermediateStops: trip.intermediateStops,
                dates: trip.startDate != null && trip.endDate != null
                    ? '${DateFormat('MMM dd').format(trip.startDate!)} - ${DateFormat('MMM dd, yyyy').format(trip.endDate!)}'
                    : 'N/A',
                slots: '${trip.maxHorses} slots available',
                info: trip.equipmentDescription ?? 'N/A',
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildTripCard({
    required String origin,
    required List<String> destinations,
    required String status,
    required Color statusColor,
    List<String>? intermediateStops,
    required String dates,
    required String slots,
    required String info,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: CommonText(
                        origin,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Icon(Icons.arrow_right_alt, size: 20, color: AppColors.secondary),
                    ),
                    Flexible(
                      child: CommonText(
                        destinations.join(', '),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(status, statusColor),
              const SizedBox(width: 4),
              const Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20),
            ],
          ),
          
          if (intermediateStops != null && intermediateStops.isNotEmpty) ...[
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 13,
                ),
                children: [
                  const TextSpan(
                    text: 'Intermediate Stops: ',
                    style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: intermediateStops.join(' • '),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          
          _buildInfoRow(Icons.calendar_today_outlined, dates),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.access_time, slots),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.chat_bubble_outline, info),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: CommonText(
        status,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: CommonText(
            text,
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
