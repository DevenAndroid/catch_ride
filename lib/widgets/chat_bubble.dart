import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String time;
  final bool isRead;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.time,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isMe) ...[
                CommonText(time, fontSize: 11, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Icon(
                  Icons.done_all,
                  size: 14,
                  color: isRead ? Colors.blue : AppColors.textSecondary,
                ),
              ] else
                CommonText(time, fontSize: 11, color: AppColors.textSecondary),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            bottom: 16,
            left: isMe ? 64 : 0,
            right: isMe ? 0 : 64,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? Colors.white : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(isMe ? 12 : 0),
              bottomRight: Radius.circular(isMe ? 0 : 12),
            ),
            border: Border.all(color: AppColors.border),
          ),
          child: CommonText(
            message,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
