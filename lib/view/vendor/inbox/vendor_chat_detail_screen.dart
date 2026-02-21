import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/inbox/vendor_inbox_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Local Message Model
// ─────────────────────────────────────────────────────────────────────────────

enum VendorMsgType { user, system }

class VendorMessage {
  final String text;
  final bool isMe;
  final String time;
  final VendorMsgType type;
  final String? bookingId;
  final String?
  bookingStatus; // "requested" | "accepted" | "declined" | "cancelled"
  final String? loadId;

  const VendorMessage({
    required this.text,
    required this.isMe,
    required this.time,
    this.type = VendorMsgType.user,
    this.bookingId,
    this.bookingStatus,
    this.loadId,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────────────────────────────────────

class VendorChatDetailScreen extends StatefulWidget {
  final VendorThread thread;

  const VendorChatDetailScreen({super.key, required this.thread});

  @override
  State<VendorChatDetailScreen> createState() => _VendorChatDetailScreenState();
}

class _VendorChatDetailScreenState extends State<VendorChatDetailScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  late List<VendorMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = _buildInitialMessages();
  }

  List<VendorMessage> _buildInitialMessages() {
    final msgs = <VendorMessage>[];

    // System message first (if thread has one)
    if (widget.thread.hasSystemMessage &&
        widget.thread.systemMessageText != null) {
      msgs.add(
        VendorMessage(
          text: widget.thread.systemMessageText!,
          isMe: false,
          time: '09:55 AM',
          type: VendorMsgType.system,
          bookingId: widget.thread.relatedBookingId,
          loadId: widget.thread.relatedLoadId,
          bookingStatus: widget.thread.systemMessageText!.contains('accepted')
              ? 'accepted'
              : widget.thread.systemMessageText!.contains('declined')
              ? 'declined'
              : widget.thread.systemMessageText!.contains('cancel')
              ? 'cancelled'
              : 'requested',
        ),
      );
    }

    // Trainer/BM opening message
    msgs.add(
      VendorMessage(
        text: widget.thread.previewText,
        isMe: false,
        time: '10:00 AM',
      ),
    );

    // Vendor service-scoped reply
    msgs.add(
      const VendorMessage(
        text:
            'Thanks for reaching out! Yes, I can help with that. What dates are you looking at?',
        isMe: true,
        time: '10:05 AM',
      ),
    );

    msgs.add(
      const VendorMessage(
        text: 'We\'re looking at March 5–7 at WEF. It would be 3 horses.',
        isMe: false,
        time: '10:08 AM',
      ),
    );

    return msgs;
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(
        VendorMessage(
          text: text,
          isMe: true,
          time: TimeOfDay.now().format(context),
        ),
      );
      _textController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBM =
        widget.thread.participantRole == VendorParticipantRole.barnManager;
    final initials = widget.thread.participantName
        .split(' ')
        .take(2)
        .map((e) => e[0])
        .join();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: isBM
                  ? AppColors.mutedGold.withOpacity(0.2)
                  : AppColors.deepNavy.withOpacity(0.12),
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isBM ? AppColors.mutedGold : AppColors.deepNavy,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.thread.participantName,
                  style: AppTextStyles.titleMedium,
                ),
                Text(
                  isBM ? 'Barn Manager' : 'Trainer',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Service-scope reminder ─────────────────────────────────────
          Container(
            width: double.infinity,
            color: AppColors.grey50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            child: Text(
              'Service-related only — availability, scope, logistics & scheduling',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey500,
                fontSize: 11,
              ),
            ),
          ),

          // ── Messages ───────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                if (msg.type == VendorMsgType.system) {
                  return Column(
                    children: [
                      _SystemBubble(message: msg),
                      if (msg.loadId != null)
                        _LoadPreviewPill(loadId: msg.loadId!),
                    ],
                  );
                }
                return _UserBubble(message: msg);
              },
            ),
          ),

          // ── Input ──────────────────────────────────────────────────────
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Reply to this conversation...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.grey100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.deepNavy,
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: 'Send',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  System Message Bubble
//  - Color-coded by booking status
//  - Tappable → deep-link to booking detail
//  - No reply affordance (read-only pill)
// ─────────────────────────────────────────────────────────────────────────────

class _SystemBubble extends StatelessWidget {
  final VendorMessage message;

  const _SystemBubble({required this.message});

  Color get _color {
    switch (message.bookingStatus) {
      case 'accepted':
        return AppColors.successGreen;
      case 'declined':
      case 'cancelled':
        return AppColors.softRed;
      default:
        return AppColors.deepNavy;
    }
  }

  IconData get _icon {
    switch (message.bookingStatus) {
      case 'accepted':
        return Icons.check_circle_outline_rounded;
      case 'declined':
        return Icons.cancel_outlined;
      case 'cancelled':
        return Icons.remove_circle_outline_rounded;
      default:
        return Icons.bookmark_border_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: message.bookingId != null
            ? () => Get.snackbar(
                'Opening Booking',
                'Navigating to Booking #${message.bookingId}',
                backgroundColor: AppColors.deepNavy,
                colorText: Colors.white,
              )
            : null,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_icon, size: 14, color: _color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  message.text,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (message.bookingId != null) ...[
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_ios_rounded, size: 10, color: _color),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  User Message Bubble
// ─────────────────────────────────────────────────────────────────────────────

class _UserBubble extends StatelessWidget {
  final VendorMessage message;

  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isMe ? AppColors.deepNavy : AppColors.grey100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(message.isMe ? 18 : 4),
            bottomRight: Radius.circular(message.isMe ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: message.isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: message.isMe ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.time,
              style: AppTextStyles.bodySmall.copyWith(
                color: message.isMe ? Colors.white60 : AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadPreviewPill extends StatelessWidget {
  final String loadId;
  const _LoadPreviewPill({required this.loadId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  size: 16,
                  color: AppColors.deepNavy,
                ),
                const SizedBox(width: 8),
                Text(
                  'Load Inquiry: #$loadId',
                  style: AppTextStyles.labelLarge.copyWith(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Wellington WEF → Lexington, KY',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Mar 10–12 • 2 Stall Request',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
            ),
          ],
        ),
      ),
    );
  }
}
