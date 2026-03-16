class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final String priority;
  final String status;
  final bool read;
  final DateTime? readAt;
  final String? actionUrl;
  final String? actionLabel;
  final String? relatedId;
  final String? relatedType;
  final String? icon;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.priority = 'medium',
    this.status = 'unread',
    this.read = false,
    this.readAt,
    this.actionUrl,
    this.actionLabel,
    this.relatedId,
    this.relatedType,
    this.icon,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] is Map ? (json['userId']['_id'] ?? '') : (json['userId'] ?? ''),
      type: json['type'] ?? 'system',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'unread',
      read: json['read'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      actionUrl: json['actionUrl'],
      actionLabel: json['actionLabel'],
      relatedId: json['relatedId'],
      relatedType: json['relatedType'],
      icon: json['icon'],
      metadata: json['metadata'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'priority': priority,
      'status': status,
      'read': read,
      'readAt': readAt?.toIso8601String(),
      'actionUrl': actionUrl,
      'actionLabel': actionLabel,
      'relatedId': relatedId,
      'relatedType': relatedType,
      'icon': icon,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
