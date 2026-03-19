import 'booking_model.dart';

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderRole;
  final String content;
  final DateTime timestamp;
  final bool read;
  final bool flagged;
  final String status;
  final String type;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderRole,
    required this.content,
    required this.timestamp,
    this.read = false,
    this.flagged = false,
    this.status = 'active',
    this.type = 'text',
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? 'Unknown',
      senderRole: json['senderRole'],
      content: json['content'] ?? '',
      timestamp: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['timestamp'] != null
                ? DateTime.parse(json['timestamp'])
                : DateTime.now()),
      read: json['read'] ?? false,
      flagged: json['flagged'] ?? false,
      status: json['status'] ?? 'active',
      type: json['type'] ?? 'text',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'read': read,
      'flagged': flagged,
      'status': status,
      'type': type,
    };
  }
}

class ChatConversation {
  final String id;
  final String conversationId;
  final String? lastMessage;
  final DateTime? date;
  final int unread;
  final String status;
  final ChatOtherUser? otherUser;
  final String? senderId; 
  final BookingModel? booking; 
  final bool pinned;
  final String? label;

  ChatConversation({
    required this.id,
    required this.conversationId,
    this.lastMessage,
    this.date,
    this.unread = 0,
    this.status = 'active',
    this.otherUser,
    this.senderId,
    this.booking,
    this.pinned = false,
    this.label,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['_id'] ?? json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      lastMessage: json['lastMessage'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      unread: json['unread'] ?? 0,
      status: json['status'] ?? 'active',
      senderId: json['senderId'],
      otherUser: json['otherUser'] != null
          ? ChatOtherUser.fromJson(json['otherUser'])
          : null,
      booking: json['booking'] != null
          ? BookingModel.fromJson(json['booking'])
          : null,
      pinned: json['pinned'] ?? false,
      label: json['label'],
    );
  }
}

class ChatOtherUser {
  final String id;
  final String name;
  final String? avatar;
  final String? role;
  final String? trainerId;
  final String? barnManagerId;
  final String? vendorId;

  ChatOtherUser({
    required this.id,
    required this.name,
    this.avatar,
    this.role,
    this.trainerId,
    this.barnManagerId,
    this.vendorId,
  });

  factory ChatOtherUser.fromJson(Map<String, dynamic> json) {
    return ChatOtherUser(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      avatar: json['avatar'],
      role: json['role'],
      trainerId: json['trainerId'],
      barnManagerId: json['barnManagerId'],
      vendorId: json['vendorId'],
    );
  }
}
