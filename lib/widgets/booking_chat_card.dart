import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/controllers/chat_controller.dart';
import 'package:catch_ride/models/booking_model.dart';
import 'package:catch_ride/models/message_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/utils/booking_chat_message_parser.dart';
import 'package:catch_ride/utils/date_util.dart';
import 'package:catch_ride/controllers/booking_controller.dart';
import 'package:catch_ride/view/trainer/booking_request_view.dart';
import 'package:catch_ride/view/vendor/booking_details_view.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Airbnb-style booking status card for chat threads.
class BookingChatMessageTileBuilder {
  BookingChatMessageTileBuilder._();

  static Widget? tryBuild({
    required ChatMessage msg,
    required bool isMe,
    required String conversationId,
    required ChatController chatController,
    required int messageIndex,
  }) {
    final strippedForBooking = stripChatSystemPrefix(msg.content);

    final pending = BookingChatMessageParser.parsePending(strippedForBooking);
    if (pending != null) {
      return _BookingPendingChatCard(
        parsed: pending,
        msg: msg,
        isMe: isMe,
        bookingId: _resolveBookingId(msg, chatController, conversationId),
        conversationId: conversationId,
        chatController: chatController,
        showReadReceipt: isMe && messageIndex == 0 && msg.read,
      );
    }

    final approval = BookingChatMessageParser.parseApproval(strippedForBooking) ??
        BookingChatMessageParser.parseConfirmed(strippedForBooking);
    if (approval != null) {
      return _BookingApprovalChatCard(
        parsed: approval,
        msg: msg,
        isMe: isMe,
        bookingId: _resolveBookingId(msg, chatController, conversationId),
        conversationId: conversationId,
        chatController: chatController,
        showReadReceipt: isMe && messageIndex == 0 && msg.read,
      );
    }

    final decline = BookingChatMessageParser.parseDecline(strippedForBooking);
    if (decline != null) {
      return _BookingDeclinedChatCard(
        parsed: decline,
        msg: msg,
        isMe: isMe,
        bookingId: _resolveBookingId(msg, chatController, conversationId),
        conversationId: conversationId,
        chatController: chatController,
        showReadReceipt: isMe && messageIndex == 0 && msg.read,
      );
    }

    final cancel = BookingChatMessageParser.parseCancel(strippedForBooking);
    if (cancel != null) {
      return _BookingCancelledChatCard(
        parsed: cancel,
        msg: msg,
        isMe: isMe,
        bookingId: _resolveBookingId(msg, chatController, conversationId),
        conversationId: conversationId,
        chatController: chatController,
        showReadReceipt: isMe && messageIndex == 0 && msg.read,
      );
    }

    final update = BookingChatMessageParser.parseUpdate(strippedForBooking);
    if (update != null) {
      return _BookingUpdatedChatCard(
        parsed: update,
        msg: msg,
        isMe: isMe,
        bookingId: _resolveBookingId(msg, chatController, conversationId),
        conversationId: conversationId,
        chatController: chatController,
        showReadReceipt: isMe && messageIndex == 0 && msg.read,
      );
    }

    return null;
  }

  static String? _resolveBookingId(
    ChatMessage msg,
    ChatController chatController,
    String conversationId,
  ) {
    final id = msg.bookingId;
    if (id != null && id.isNotEmpty) return id;

    final stripped = stripChatSystemPrefix(msg.content);
    final isBookingRelated = BookingChatMessageParser.parsePending(stripped) != null ||
        BookingChatMessageParser.parseApproval(stripped) != null ||
        BookingChatMessageParser.parseConfirmed(stripped) != null ||
        BookingChatMessageParser.parseDecline(stripped) != null ||
        BookingChatMessageParser.parseCancel(stripped) != null ||
        BookingChatMessageParser.parseUpdate(stripped) != null;
    if (!isBookingRelated) return null;

    final convo = chatController.conversations.firstWhereOrNull(
      (c) => c.conversationId == conversationId,
    );
    final fromConvo = convo?.booking?.id;
    if (fromConvo != null && fromConvo.isNotEmpty) return fromConvo;
    return null;
  }
}

String _roleDisplayLabel(String? role) {
  switch (role) {
    case 'trainer':
      return 'Trainer';
    case 'barn_manager':
      return 'Barn Manager';
    case 'service_provider':
      return 'Service Provider';
    default:
      return 'Professional';
  }
}

bool _isServiceProviderBooking(BookingModel booking) {
  final vendorId = booking.vendorId?.trim();
  if (vendorId != null && vendorId.isNotEmpty) return true;
  if (booking.vendorBundleLines.isNotEmpty) return true;

  final t = booking.type.toLowerCase();
  if (t == 'multi-service' || t == 'vendor') return true;

  const vendorTypes = {
    'grooming',
    'braiding',
    'clipping',
    'farrier',
    'bodywork',
    'shipping',
    'transportation',
  };
  if (vendorTypes.contains(t)) return true;
  if (t.contains('farrier')) return true;
  return false;
}

Future<void> _openBookingDetails({
  required String? bookingId,
  required String fallbackStatus,
  required String conversationId,
  required ChatController chatController,
}) async {
  if (bookingId == null || bookingId.isEmpty) {
    Get.snackbar(
      'Booking',
      'Please open this booking from the Bookings tab.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.errorBg,
      colorText: AppColors.errorPrimary,
    );
    return;
  }

  try {
    final api = Get.find<ApiService>();
    final response = await api.getRequest('/bookings/$bookingId');
    if (response.statusCode != 200 || response.body['data'] == null) {
      Get.snackbar(
        'Booking',
        'Please try again or open this booking from the Bookings tab.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorBg,
        colorText: AppColors.errorPrimary,
      );
      return;
    }

    final booking = BookingModel.fromJson(response.body['data']);

    // Horse / barn bookings → trainer flow. Service provider (vendor) bookings → vendor details.
    if (_isServiceProviderBooking(booking)) {
      if (!Get.isRegistered<BookingController>()) {
        Get.put(BookingController());
      }
      Get.to(() => BookingDetailsView(booking: booking));
      return;
    }

    final auth = Get.find<AuthController>();
    final me = auth.currentUser.value?.id ?? '';
    final role = auth.currentUser.value?.role ?? '';
    final imClient =
        booking.clientId != null && booking.clientId!.isNotEmpty && booking.clientId == me;
    final bool isProfessional =
        role == 'trainer' || role == 'barn_manager' || role == 'admin';

    final convo = chatController.conversations.firstWhereOrNull(
      (c) => c.conversationId == conversationId,
    );
    final other = convo?.otherUser;

    var otherId = other?.id ?? '';
    var otherName = other?.name ?? '';
    var otherImage = other?.avatar ?? '';

    if (imClient) {
      if (otherId.isEmpty) {
        otherId = booking.trainerUserId ?? booking.trainerId ?? '';
      }
      if (otherName.isEmpty) otherName = booking.trainerName ?? '';
      if (otherImage.isEmpty) otherImage = booking.trainerImage ?? '';
    } else {
      if (otherId.isEmpty) otherId = booking.clientId ?? '';
      if (otherName.isEmpty) otherName = booking.clientName ?? '';
      if (otherImage.isEmpty) otherImage = booking.clientImage ?? '';
    }

    final String trainerTeamUserId =
        booking.trainerUserId ?? booking.trainerId ?? me;
    final String myTeamId = imClient
        ? trainerTeamUserId
        : (isProfessional ? trainerTeamUserId : (booking.clientId ?? ''));

    Get.to(
      () => BookingRequestView(
        horseId: booking.horseId,
        fromBooking: true,
        bookingId: booking.id ?? bookingId,
        bookingStatus:
            booking.status.isNotEmpty ? booking.status : fallbackStatus,
        otherId: otherId.isNotEmpty ? otherId : null,
        otherName: otherName.isNotEmpty ? otherName : null,
        otherImage: otherImage.isNotEmpty ? otherImage : null,
        myTeamId: myTeamId.isNotEmpty ? myTeamId : null,
        openedFromConversationId: conversationId,
      ),
    );
  } catch (e) {
    Get.snackbar(
      'Booking',
      'Please try again or open this booking from the Bookings tab.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.errorBg,
      colorText: AppColors.errorPrimary,
    );
  }
}

class _BookingApprovalChatCard extends StatelessWidget {
  final ParsedBookingApprovalMessage parsed;
  final ChatMessage msg;
  final bool isMe;
  final String? bookingId;
  final String conversationId;
  final ChatController chatController;
  final bool showReadReceipt;

  const _BookingApprovalChatCard({
    required this.parsed,
    required this.msg,
    required this.isMe,
    required this.bookingId,
    required this.conversationId,
    required this.chatController,
    required this.showReadReceipt,
  });

  @override
  Widget build(BuildContext context) {
    final timeLabel = DateFormat.jm().format(msg.timestamp.toLocal());
    final metaParts = <String>[
      msg.senderName,
      _roleDisplayLabel(msg.senderRole),
      timeLabel,
    ];
    final metaLine = metaParts.join(' · ');

    final dateLine = DateUtil.formatDisplayDate(parsed.dateRaw);

    final cardBody = _BookingCardShell(
      statusTitle: 'Request accepted',
      headline: parsed.horseName,
      subtitle: dateLine,
      footnote: parsed.notes != null && parsed.notes!.isNotEmpty
          ? 'Notes: ${parsed.notes}'
          : null,
      onShowDetails: () => _openBookingDetails(
        bookingId: bookingId,
        fallbackStatus: 'accepted',
        conversationId: conversationId,
        chatController: chatController,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: CommonText(
              metaLine,
              fontSize: AppTextSizes.size12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              textAlign: isMe ? TextAlign.right : TextAlign.left,
            ),
          ),
          const SizedBox(height: 8),
          if (isMe)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(child: cardBody),
                const SizedBox(width: 8),
                CommonImageView(
                  url: msg.senderImage ?? '',
                  height: 36,
                  width: 36,
                  shape: BoxShape.circle,
                  isUserImage: true,
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CommonImageView(
                  url: msg.senderImage ?? '',
                  height: 36,
                  width: 36,
                  shape: BoxShape.circle,
                  isUserImage: true,
                ),
                const SizedBox(width: 8),
                Expanded(child: cardBody),
              ],
            ),
          if (showReadReceipt) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: CommonText(
                'Seen',
                fontSize: AppTextSizes.size12,
                color: AppColors.textSecondary,
                textAlign: isMe ? TextAlign.right : TextAlign.left,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BookingDeclinedChatCard extends StatelessWidget {
  final ParsedBookingDeclineMessage parsed;
  final ChatMessage msg;
  final bool isMe;
  final String? bookingId;
  final String conversationId;
  final ChatController chatController;
  final bool showReadReceipt;

  const _BookingDeclinedChatCard({
    required this.parsed,
    required this.msg,
    required this.isMe,
    required this.bookingId,
    required this.conversationId,
    required this.chatController,
    required this.showReadReceipt,
  });

  @override
  Widget build(BuildContext context) {
    final timeLabel = DateFormat.jm().format(msg.timestamp.toLocal());
    final metaParts = <String>[
      msg.senderName,
      _roleDisplayLabel(msg.senderRole),
      timeLabel,
    ];
    final metaLine = metaParts.join(' · ');

    final dateLine = DateUtil.formatDisplayDate(parsed.dateRaw);

    final cardBody = _BookingCardShell(
      statusTitle: 'Request declined',
      headline: parsed.horseName,
      subtitle: dateLine,
      footnote: parsed.reason != null && parsed.reason!.isNotEmpty
          ? 'Reason: ${parsed.reason}'
          : null,
      statusAccent: AppColors.errorPrimary,
      icon: Icons.cancel_outlined,
      iconBackground: AppColors.errorBg,
      iconColor: AppColors.errorPrimary,
      onShowDetails: () => _openBookingDetails(
        bookingId: bookingId,
        fallbackStatus: 'rejected',
        conversationId: conversationId,
        chatController: chatController,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: CommonText(
              metaLine,
              fontSize: AppTextSizes.size12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              textAlign: isMe ? TextAlign.right : TextAlign.left,
            ),
          ),
          const SizedBox(height: 8),
          if (isMe)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(child: cardBody),
                const SizedBox(width: 8),
                CommonImageView(
                  url: msg.senderImage ?? '',
                  height: 36,
                  width: 36,
                  shape: BoxShape.circle,
                  isUserImage: true,
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CommonImageView(
                  url: msg.senderImage ?? '',
                  height: 36,
                  width: 36,
                  shape: BoxShape.circle,
                  isUserImage: true,
                ),
                const SizedBox(width: 8),
                Expanded(child: cardBody),
              ],
            ),
          if (showReadReceipt) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: CommonText(
                'Seen',
                fontSize: AppTextSizes.size12,
                color: AppColors.textSecondary,
                textAlign: isMe ? TextAlign.right : TextAlign.left,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BookingCancelledChatCard extends StatelessWidget {
  final ParsedBookingDeclineMessage parsed;
  final ChatMessage msg;
  final bool isMe;
  final String? bookingId;
  final String conversationId;
  final ChatController chatController;
  final bool showReadReceipt;

  const _BookingCancelledChatCard({
    required this.parsed,
    required this.msg,
    required this.isMe,
    required this.bookingId,
    required this.conversationId,
    required this.chatController,
    required this.showReadReceipt,
  });

  @override
  Widget build(BuildContext context) {
    final timeLabel = DateFormat.jm().format(msg.timestamp.toLocal());
    final metaParts = <String>[
      msg.senderName,
      _roleDisplayLabel(msg.senderRole),
      timeLabel,
    ];
    final metaLine = metaParts.join(' · ');

    final dateLine = DateUtil.formatDisplayDate(parsed.dateRaw);

    final cardBody = _BookingCardShell(
      statusTitle: 'Booking cancelled',
      headline: parsed.horseName,
      subtitle: dateLine,
      footnote: parsed.reason != null && parsed.reason!.isNotEmpty
          ? 'Reason: ${parsed.reason}'
          : null,
      statusAccent: AppColors.errorPrimary,
      icon: Icons.event_busy_rounded,
      iconBackground: AppColors.errorBg,
      iconColor: AppColors.errorPrimary,
      onShowDetails: () => _openBookingDetails(
        bookingId: bookingId,
        fallbackStatus: 'cancelled',
        conversationId: conversationId,
        chatController: chatController,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: CommonText(
              metaLine,
              fontSize: AppTextSizes.size12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              textAlign: isMe ? TextAlign.right : TextAlign.left,
            ),
          ),
          const SizedBox(height: 8),
          if (isMe)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(child: cardBody),
                const SizedBox(width: 8),
                CommonImageView(
                  url: msg.senderImage ?? '',
                  height: 36,
                  width: 36,
                  shape: BoxShape.circle,
                  isUserImage: true,
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CommonImageView(
                  url: msg.senderImage ?? '',
                  height: 36,
                  width: 36,
                  shape: BoxShape.circle,
                  isUserImage: true,
                ),
                const SizedBox(width: 8),
                Expanded(child: cardBody),
              ],
            ),
          if (showReadReceipt) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: CommonText(
                'Seen',
                fontSize: AppTextSizes.size12,
                color: AppColors.textSecondary,
                textAlign: isMe ? TextAlign.right : TextAlign.left,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BookingPendingChatCard extends StatefulWidget {
  final ParsedBookingPendingMessage parsed;
  final ChatMessage msg;
  final bool isMe;
  final String? bookingId;
  final String conversationId;
  final ChatController chatController;
  final bool showReadReceipt;

  const _BookingPendingChatCard({
    required this.parsed,
    required this.msg,
    required this.isMe,
    required this.bookingId,
    required this.conversationId,
    required this.chatController,
    required this.showReadReceipt,
  });

  @override
  State<_BookingPendingChatCard> createState() => _BookingPendingChatCardState();
}

class _BookingPendingChatCardState extends State<_BookingPendingChatCard> {
  String? _trainerNotes;

  @override
  void initState() {
    super.initState();
    _loadTrainerNotes();
  }

  @override
  void didUpdateWidget(covariant _BookingPendingChatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookingId != widget.bookingId ||
        oldWidget.msg.bookingNotes != widget.msg.bookingNotes ||
        oldWidget.msg.id != widget.msg.id) {
      _trainerNotes = null;
      _loadTrainerNotes();
    }
  }

  Future<void> _loadTrainerNotes() async {
    final notes = await widget.chatController.bookingNotesForId(
      widget.bookingId,
      fromMessage: widget.msg.bookingNotes ?? widget.parsed.notes,
      conversationId: widget.conversationId,
    );
    if (!mounted) return;
    setState(() => _trainerNotes = notes);
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel = DateFormat.jm().format(widget.msg.timestamp.toLocal());
    final metaParts = <String>[
      widget.msg.senderName,
      _roleDisplayLabel(widget.msg.senderRole),
      timeLabel,
    ];
    final metaLine = metaParts.join(' · ');

    final dateLine = DateUtil.formatDisplayDate(widget.parsed.dateRaw);

    final footnoteParts = <String>['Waiting for professional approval.'];
    if (_trainerNotes != null && _trainerNotes!.isNotEmpty) {
      footnoteParts.add('Notes for trainer: $_trainerNotes');
    }

    final cardBody = _BookingCardShell(
      statusTitle: 'Request pending',
      headline: widget.parsed.horseName,
      subtitle: dateLine,
      footnote: footnoteParts.join('\n'),
      footnoteMaxLines: 8,
      onShowDetails: () => _openBookingDetails(
        bookingId: widget.bookingId,
        fallbackStatus: 'pending',
        conversationId: widget.conversationId,
        chatController: widget.chatController,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment:
            widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: CommonText(
              metaLine,
              fontSize: AppTextSizes.size12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              textAlign: widget.isMe ? TextAlign.right : TextAlign.left,
            ),
          ),
          const SizedBox(height: 8),
          if (widget.isMe)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(child: cardBody),
                const SizedBox(width: 8),
                CommonImageView(
                  url: widget.msg.senderImage ?? '',
                  height: 36,
                  width: 36,
                  shape: BoxShape.circle,
                  isUserImage: true,
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CommonImageView(
                  url: widget.msg.senderImage ?? '',
                  height: 36,
                  width: 36,
                  shape: BoxShape.circle,
                  isUserImage: true,
                ),
                const SizedBox(width: 8),
                Expanded(child: cardBody),
              ],
            ),
          if (widget.showReadReceipt) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: CommonText(
                'Seen',
                fontSize: AppTextSizes.size12,
                color: AppColors.textSecondary,
                textAlign: widget.isMe ? TextAlign.right : TextAlign.left,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BookingUpdatedChatCard extends StatelessWidget {
  final ParsedBookingUpdateMessage parsed;
  final ChatMessage msg;
  final bool isMe;
  final String? bookingId;
  final String conversationId;
  final ChatController chatController;
  final bool showReadReceipt;

  const _BookingUpdatedChatCard({
    required this.parsed,
    required this.msg,
    required this.isMe,
    required this.bookingId,
    required this.conversationId,
    required this.chatController,
    required this.showReadReceipt,
  });

  @override
  Widget build(BuildContext context) {
    final timeLabel = DateFormat.jm().format(msg.timestamp.toLocal());
    final metaParts = <String>[
      msg.senderName,
      _roleDisplayLabel(msg.senderRole),
      timeLabel,
    ];
    final metaLine = metaParts.join(' · ');

    final lines = <String>[];
    if (parsed.location != null && parsed.location!.isNotEmpty) {
      lines.add('Location: ${parsed.location}');
    }
    final st = parsed.startTime ?? '';
    final et = parsed.endTime ?? '';
    if (st.isNotEmpty || et.isNotEmpty) {
      lines.add(
        'Time: ${st.isNotEmpty ? st : '—'} – ${et.isNotEmpty ? et : '—'}',
      );
    }
    if (parsed.notes != null && parsed.notes!.isNotEmpty) {
      lines.add('Notes: ${parsed.notes}');
    }
    final footnote = lines.isEmpty ? null : lines.join('\n');

    final cardBody = _BookingCardShell(
      statusTitle: 'Booking updated',
      headline: parsed.horseName,
      subtitle: parsed.date,
      footnote: footnote,
      onShowDetails: () => _openBookingDetails(
        bookingId: bookingId,
        fallbackStatus: 'confirmed',
        conversationId: conversationId,
        chatController: chatController,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: CommonText(
              metaLine,
              fontSize: AppTextSizes.size12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              textAlign: isMe ? TextAlign.right : TextAlign.left,
            ),
          ),
          const SizedBox(height: 8),
          if (isMe)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(child: cardBody),
                const SizedBox(width: 8),
                CommonImageView(
                  url: msg.senderImage ?? '',
                  height: 36,
                  width: 36,
                  shape: BoxShape.circle,
                  isUserImage: true,
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CommonImageView(
                  url: msg.senderImage ?? '',
                  height: 36,
                  width: 36,
                  shape: BoxShape.circle,
                  isUserImage: true,
                ),
                const SizedBox(width: 8),
                Expanded(child: cardBody),
              ],
            ),
          if (showReadReceipt) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: CommonText(
                'Seen',
                fontSize: AppTextSizes.size12,
                color: AppColors.textSecondary,
                textAlign: isMe ? TextAlign.right : TextAlign.left,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BookingCardShell extends StatelessWidget {
  final String statusTitle;
  final String headline;
  final String subtitle;
  final String? footnote;
  final int footnoteMaxLines;
  final VoidCallback onShowDetails;
  // Optional accent for status-specific cards (e.g. declined uses an error tint).
  final Color? statusAccent;
  final IconData? icon;
  final Color? iconBackground;
  final Color? iconColor;

  const _BookingCardShell({
    required this.statusTitle,
    required this.headline,
    required this.subtitle,
    this.footnote,
    this.footnoteMaxLines = 4,
    required this.onShowDetails,
    this.statusAccent,
    this.icon,
    this.iconBackground,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedIcon = icon ?? Icons.calendar_month_rounded;
    final resolvedIconBg = iconBackground ?? AppColors.tabBackground;
    final resolvedIconColor =
        iconColor ?? AppColors.textPrimary.withValues(alpha: 0.85);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      statusTitle,
                      fontSize: AppTextSizes.size12,
                      fontWeight: FontWeight.w700,
                      color: statusAccent ?? AppColors.textPrimary,
                    ),
                    const SizedBox(height: 6),
                    CommonText(
                      headline,
                      fontSize: AppTextSizes.size18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 4),
                    CommonText(
                      subtitle,
                      fontSize: AppTextSizes.size14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                    if (footnote != null && footnote!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      CommonText(
                        footnote!,
                        fontSize: AppTextSizes.size12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        maxLines: footnoteMaxLines,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: resolvedIconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  resolvedIcon,
                  size: 22,
                  color: resolvedIconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Material(
            color: AppColors.tabBackground,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: onShowDetails,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: CommonText(
                    'Show details',
                    fontSize: AppTextSizes.size14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
