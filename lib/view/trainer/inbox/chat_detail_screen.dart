
import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

class ChatDetailScreen extends StatefulWidget {
  final String userName;
  const ChatDetailScreen({super.key, required this.userName});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final List<Message> _messages = [
    Message(text: 'Hello, is "Thunderbolt" still available for lease?', isMe: false, time: '10:00 AM'),
    Message(text: 'Yes, he is available! Are you looking for full or partial lease?', isMe: true, time: '10:05 AM'),
  ];
  final TextEditingController _textController = TextEditingController();

  void _sendMessage() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        _messages.add(Message(text: _textController.text, isMe: true, time: 'Now'));
        _textController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              child: Text(widget.userName[0], style: AppTextStyles.labelLarge),
            ),
            const SizedBox(width: 8),
            Text(widget.userName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: message.isMe ? AppColors.deepNavy : AppColors.grey200,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(message.isMe ? 16 : 0),
                        bottomRight: Radius.circular(message.isMe ? 0 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
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
                            color: message.isMe ? Colors.white70 : AppColors.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: AppColors.deepNavy),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String text;
  final bool isMe;
  final String time;

  Message({required this.text, required this.isMe, required this.time});
}
