import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/view/vendor/braiding/chat/requests_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BraidingChatView extends StatelessWidget {
  const BraidingChatView({super.key});

  final List<Map<String, dynamic>> _chats = const [
    {
      'name': 'Sarah Jones',
      'message': 'Thanks so much, happy with that.',
      'time': '2 mins ago',
      'isUnread': true,
      'avatar': 'https://i.pravatar.cc/150?u=sarah'
    },
    {
      'name': 'Demi Wikinson',
      'message': 'Got you a coffee',
      'time': '2 mins ago',
      'isUnread': false,
      'avatar': 'https://i.pravatar.cc/150?u=demi'
    },
    {
      'name': 'Candice Wu',
      'message': 'Great to see you again!',
      'time': '3 hours ago',
      'isUnread': false,
      'avatar': 'https://i.pravatar.cc/150?u=candice'
    },
    {
      'name': 'Natali Craig',
      'message': 'We should ask Oli about this...',
      'time': '6 hours ago',
      'isUnread': false,
      'avatar': 'https://i.pravatar.cc/150?u=natali'
    },
    {
      'name': 'Drew Cano',
      'message': 'Okay, see you then.',
      'time': '12 hours ago',
      'isUnread': false,
      'avatar': 'https://i.pravatar.cc/150?u=drew'
    },
    {
      'name': 'Drew Cano',
      'message': 'Okay, see you then.',
      'time': '12 hours ago',
      'isUnread': false,
      'avatar': 'https://i.pravatar.cc/150?u=drew2'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const CommonText('Inbox', fontSize: AppTextSizes.size24, fontWeight: FontWeight.bold),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: GestureDetector(
                onTap: () => Get.to(() => const RequestsView()),
                child: Row(
                  children: const [
                    CircleAvatar(radius: 4, backgroundColor: Colors.blue),
                    SizedBox(width: 8),
                    CommonText('Requests', color: Colors.blue, fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _chats.length,
        separatorBuilder: (context, index) => Divider(height: 1, thickness: 1, color: AppColors.dividerColor, indent: 80, endIndent: 20),
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(chat['avatar']),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(chat['name'], fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
                CommonText(chat['time'], fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CommonText(
                      chat['message'],
                      fontSize: AppTextSizes.size14,
                      color: AppColors.textSecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (chat['isUnread'] as bool)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(color: Color(0xFF13CA8B), shape: BoxShape.circle),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
