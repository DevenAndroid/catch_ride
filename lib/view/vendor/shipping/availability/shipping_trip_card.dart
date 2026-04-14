import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/models/trip_model.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ShippingTripCard extends StatelessWidget {
  final TripModel trip;

  const ShippingTripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final dates = trip.startDate != null && trip.endDate != null
        ? '${DateFormat('MMM dd').format(trip.startDate!)} - ${DateFormat('MMM dd, yyyy').format(trip.endDate!)}'
        : 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                        trip.origin ?? 'N/A',
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
                        trip.destination ?? 'N/A',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(trip.status),
            ],
          ),
          if (trip.intermediateStops.isNotEmpty) ...[
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                style: GoogleFonts.inter(fontSize: 13),
                children: [
                  const TextSpan(
                    text: 'Intermediate Stops: ',
                    style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: trip.intermediateStops.join(' • '),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildInfoRow(Icons.calendar_today_outlined, dates),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.access_time, '${trip.maxHorses} slots available'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.chat_bubble_outline, trip.routeNotes ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = const Color(0xFF13CA8B);
    switch (status.toLowerCase()) {
      case 'limited':
        color = const Color(0xFFF79009);
        break;
      case 'full':
        color = const Color(0xFFF04438);
        break;
    }

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
