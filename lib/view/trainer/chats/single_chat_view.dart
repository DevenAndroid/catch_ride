import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SingleChatView extends StatelessWidget {
  final String name;
  final String image;

  const SingleChatView({super.key, required this.name, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            CircleAvatar(radius: 20, backgroundImage: NetworkImage(image)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  name,
                  fontSize: AppTextSizes.size16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                const CommonText(
                  'Professional Horse Trainer',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTimestamp('Thursday 11:40am'),
                const ChatBubble(
                  message:
                      "Hi team, I'm happy to share that I've completed the requirements document! Looking forward to your feedback.",
                  isMe: false,
                  time: 'Thursday 11:40am',
                ),
                const ChatBubble(
                  message: "That's awesome! Your excitement is contagious.",
                  isMe: true,
                  time: 'Thursday 11:41am',
                  isRead: true,
                ),
                _buildDateSeparator('Today'),
                const ChatBubble(
                  message:
                      "I'm thrilled to let you know that I've finished the requirements document!",
                  isMe: false,
                  time: 'Thursday 11:40am',
                ),
                const ChatBubble(
                  message: "That's wonderful news!",
                  isMe: true,
                  time: 'Thursday 11:41am',
                  isRead: false,
                ),
              ],
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildTimestamp(String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CommonText(time, fontSize: 12, color: AppColors.textSecondary),
    );
  }

  Widget _buildDateSeparator(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CommonText(
              label,
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const Expanded(child: Divider(color: AppColors.border)),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Message',
                  hintStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  fillColor: const Color(0xFFF9FAFB),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  suffixIcon: const Icon(
                    Icons.attach_file,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 48,
              width: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF101828),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
