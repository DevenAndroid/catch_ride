import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/models/message_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../constant/app_colors.dart';
import 'booking_controller.dart';

class ChatController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final SocketService _socketService = Get.find<SocketService>();
  final AuthController _authController = Get.find<AuthController>();
  final Logger _logger = Logger();

  final RxList<ChatConversation> conversations = <ChatConversation>[].obs;
  final RxList<ChatMessage> currentMessages = <ChatMessage>[].obs;
  final RxBool isLoadingConversations = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxString activeConversationId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchConversations();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    // 1. Message Received
    _socketService.socket.on('message:received', (data) {
      final message = ChatMessage.fromJson(data);
      _handleIncomingMessage(message);
    });

    // 2. Message Sent Confirmation (to replace temp IDs if we use them)
    _socketService.socket.on('message:sent', (data) {
      final message = ChatMessage.fromJson(data['message']);
      final tempId = data['tempId'];
      _handleSentConfirmation(tempId, message);
    });

    // 3. Status Updated
    _socketService.socket.on('conversation:status:updated', (data) {
      final String cid = data['conversationId'];
      final String status = data['status'];
      _handleStatusUpdate(cid, status);
    });
  }

  // ─── API ACTIONS ─────────────────────────────────────────────────────────────

  Future<void> fetchConversations() async {
    try {
      isLoadingConversations.value = true;
      final response = await _apiService.getRequest(AppUrls.conversations);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.body['data'] ?? [];
        conversations.value = data
            .map((json) => ChatConversation.fromJson(json))
            .toList();
      }

      if (conversations.isEmpty) {
        // No conversations found
      }
    } catch (e) {
      _logger.e('Error fetching conversations: $e');
    } finally {
      isLoadingConversations.value = false;
    }
  }

  Future<List<ChatConversation>> fetchConversationsForUser(String userId) async {
    try {
      final response = await _apiService.getRequest(
        AppUrls.conversations,
        query: {'userId': userId},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.body['data'] ?? [];
        final list = data
            .map((json) => ChatConversation.fromJson(json))
            .toList();
        // Sort by date (desc)
        list.sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
        return list;
      }
      return [];
    } catch (e) {
      _logger.e('Error fetching conversations for user $userId: $e');
      return [];
    }
  }

  Future<void> fetchMessages(String convoId) async {
    try {
      // Leave old room if any
      if (activeConversationId.isNotEmpty && activeConversationId.value != convoId) {
        _socketService.emit('conversation:leave', activeConversationId.value);
      }

      activeConversationId.value = convoId;
      isLoadingMessages.value = true;
      currentMessages.clear();

      // Join new room
      _socketService.emit('conversation:join', convoId);

      // Production API Call
      final response = await _apiService.getRequest(
        '${AppUrls.messagesByConversation}$convoId/messages',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.body['data'] ?? [];
        currentMessages.value = data
            .map((json) => ChatMessage.fromJson(json))
            .toList();

        // Mark as read locally and on server
        _socketService.emit('message:read', {'conversationId': convoId});
      }
    } catch (e) {
      _logger.e('Error fetching messages: $e');
    } finally {
      isLoadingMessages.value = false;
    }
  }

  void clearActiveConversation() {
    if (activeConversationId.isNotEmpty) {
      _socketService.emit('conversation:leave', activeConversationId.value);
    }
    activeConversationId.value = '';
    currentMessages.clear();
  }

  void sendMessage(String content, {String? receiverId}) {
    if (content.trim().isEmpty || activeConversationId.isEmpty) return;

    if (!_socketService.isConnected.value) {
      Get.snackbar(
        'Connection Error',
        'You are currently offline. Please check your internet connection and try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
      );
      return;
    }

    final tempId = 'temp-${DateTime.now().millisecondsSinceEpoch}';

    // Create optimistic message
    final optimisticMsg = ChatMessage(
      id: tempId,
      conversationId: activeConversationId.value,
      senderId: _authController.currentUser.value?.id ?? '',
      senderName: 'You',
      content: content,
      timestamp: DateTime.now(),
      status: 'active',
    );

    currentMessages.add(optimisticMsg);

    // Emit via socket
    _socketService.emit('message:send', {
      'conversationId': activeConversationId.value,
      'content': content,
      'tempId': tempId,
      'receiverId': receiverId,
    });
  }

  Future<bool> acceptRequest(String conversationId) async {
    try {
      final response = await _apiService.postRequest(
        '${AppUrls.acceptChatRequest}$conversationId/accept',
        {},
      );
      if (response.statusCode == 200) {
        _handleStatusUpdate(conversationId, 'request-accepted');
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Error accepting request: $e');
      return false;
    }
  }

  Future<bool> declineRequest(String conversationId) async {
    try {
      final response = await _apiService.postRequest(
        '${AppUrls.declineChatRequest}$conversationId/decline',
        {},
      );
      if (response.statusCode == 200) {
        _handleStatusUpdate(conversationId, 'request-declined');
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Error declining request: $e');
      return false;
    }
  }

  Future<bool> deleteConversation(String conversationId) async {
    try {
      final response = await _apiService.deleteRequest(
        '${AppUrls.conversations.replaceAll('/conversations', '/conversation')}/$conversationId',
      );
      if (response.statusCode == 200) {
        conversations.removeWhere((c) => c.conversationId == conversationId);
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Error deleting conversation: $e');
      return false;
    }
  }

  // ─── INTERNAL HANDLERS ───────────────────────────────────────────────────────

  void _handleIncomingMessage(ChatMessage message) {
    if (message.conversationId == activeConversationId.value) {
      // 1. Check if ID already exists (common if we get double-emitted or if _handleSentConfirmation already replaced it)
      bool exists = currentMessages.any((m) => m.id == message.id);

      // 2. For the SENDER: check if we have a matching optimistic message (same content)
      // that is still in "temp" status. Replace it to avoid flickering.
      final String currentUserId = _authController.currentUser.value?.id ?? '';
      if (!exists && message.senderId == currentUserId) {
        final optimisticIndex = currentMessages.indexWhere(
          (m) => m.id.startsWith('temp-') && m.content == message.content,
        );
        if (optimisticIndex != -1) {
          currentMessages[optimisticIndex] = message;
          exists = true;
        }
      }

      if (!exists) {
        currentMessages.add(message);
      }

      _socketService.emit('message:read', {
        'conversationId': message.conversationId,
      });
    }

    // Update conversation list item
    final index = conversations.indexWhere(
      (c) => c.conversationId == message.conversationId,
    );
    if (index != -1) {
      // Move to top and update last message
      // Note: In a real app, you'd likely want to refresh the conversation list or update the object
      fetchConversations(); // Simplest way to keep sync for now
    } else {
      fetchConversations(); // New conversation appeared
    }
  }

  void _handleSentConfirmation(String tempId, ChatMessage message) {
    // 1. Remove any other instances of this real ID that might have arrived before the confirmation
    currentMessages.removeWhere((m) => m.id == message.id && m.id != tempId);

    // 2. Find and replace the optimistic message
    final index = currentMessages.indexWhere((m) => m.id == tempId);
    if (index != -1) {
      currentMessages[index] = message;
    } else {
      // If the optimistic message is gone but we didn't find the real ID yet, add it
      if (!currentMessages.any((m) => m.id == message.id)) {
        currentMessages.add(message);
      }
    }
    fetchConversations(); // Sync last message in sidebar
  }

  void _handleStatusUpdate(String conversationId, String status) {
    if (conversationId == activeConversationId.value) {
      // Update local messages if they share this status
      final updatedMessages = currentMessages
          .map(
            (m) => ChatMessage(
              id: m.id,
              conversationId: m.conversationId,
              senderId: m.senderId,
              senderName: m.senderName,
              senderRole: m.senderRole,
              content: m.content,
              timestamp: m.timestamp,
              read: m.read,
              flagged: m.flagged,
              status: status,
              type: m.type,
            ),
          )
          .toList();
      currentMessages.value = updatedMessages;
    }
    fetchConversations();

    // Refresh bookings to reflect new status (confirmed/rejected)
    if (Get.isRegistered<BookingController>()) {
      final bc = Get.find<BookingController>();
      bc.fetchBookings(type: 'received');
      bc.fetchBookings(type: 'sent');
    }
  }
}
