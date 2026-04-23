import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/booking_controller.dart';
import 'package:catch_ride/models/booking_model.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../trainer/chats/single_chat_view.dart';

class StandaloneBookingCard extends StatefulWidget {
  final BookingModel booking;
  final VoidCallback onAction;

  const StandaloneBookingCard({
    super.key,
    required this.booking,
    required this.onAction,
  });

  @override
  State<StandaloneBookingCard> createState() => _StandaloneBookingCardState();
}

class _StandaloneBookingCardState extends State<StandaloneBookingCard> {
  bool _isAccepting = false;
  bool _isRejecting = false;

  bool get _isBusy => _isAccepting || _isRejecting;

  @override
  Widget build(BuildContext context) {
    final BookingController controller = Get.find<BookingController>();

    final String name = (widget.booking.trainerName != null && widget.booking.trainerName != 'Unknown' && widget.booking.trainerName!.isNotEmpty)
        ? widget.booking.trainerName!
        : (widget.booking.clientName ?? 'Unknown');
    final String? avatar = widget.booking.trainerImage ?? widget.booking.clientImage; 

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F9FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                CommonImageView(
                 url: widget.booking.clientImage ?? avatar,
                  height: 40,
                  width: 40,
                  shape: BoxShape.circle,
                  isUserImage: true,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        "Requester : $name",
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 2),
                      const CommonText(
                        "Direct Booking",
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CommonImageView(
                        url: widget.booking.clientImage ?? avatar,
                        height: 80,
                        width: 80,
                        radius: 8,
                        fit: BoxFit.cover,
                        isUserImage: true,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: CommonText(
                            widget.booking.type,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CommonText(
                              widget.booking.horseName ?? "Booking Request",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: CommonText(
                                widget.booking.location ?? 'N/A',
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            CommonText(
                              widget.booking.date,
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.booking.notes != null && widget.booking.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CommonText(
                    'Notes:',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 4),
                  CommonText(
                    widget.booking.notes!,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    maxLines: 5,
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _isBusy
                        ? null
                        : () async {
                              if (widget.booking.id != null) {
                                setState(() => _isRejecting = true);
                                bool success = await controller.updateBookingStatus(widget.booking.id!, 'declined');
                                if (mounted) setState(() => _isRejecting = false);
                                if (success) {
                                  widget.onAction();
                                }
                              }
                            },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _isRejecting ? Colors.grey.shade100 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: _isRejecting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textPrimary,
                              ),
                            )
                          : const CommonText(
                              'Reject',
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _isBusy
                        ? null
                        : () async {
                              if (widget.booking.id != null) {
                                setState(() => _isAccepting = true);
                                final dynamic result = await controller.updateBookingStatus(widget.booking.id!, 'confirmed');
                                if (mounted) setState(() => _isAccepting = false);
                                
                                if (result != null && result is Map) {
                                  widget.onAction();
                                  final String? conversationId = result['conversationId'];
                                  if (conversationId != null) {
                                    String? otherId;
                                    if (widget.booking.trainerId is Map) {
                                      otherId = (widget.booking.trainerId as Map)['_id'];
                                    } else if (widget.booking.trainerId is String) {
                                      otherId = widget.booking.trainerId as String;
                                    }

                                    Get.to(() => SingleChatView(
                                      name: name,
                                      image: avatar ?? '',
                                      conversationId: conversationId,
                                      otherId: otherId,
                                    ));
                                  }
                                }
                              }
                            },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _isAccepting ? const Color(0xFF0e7a68) : const Color(0xff12937E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: _isAccepting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const CommonText(
                              'Accept',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
