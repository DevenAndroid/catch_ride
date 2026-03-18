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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? AppColors.secondary : const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isMe
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: CommonText(
              message,
              fontSize: 15,
              color: isMe ? Colors.white : AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          if (isMe && isRead) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonText(
                  'Seen $time',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
