import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/models/message_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../constant/app_colors.dart';
import '../view/trainer/chats/single_chat_view.dart';
import 'booking_controller.dart';
import 'profile_controller.dart';

class ChatController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final SocketService _socketService = Get.find<SocketService>();
  final AuthController _authController = Get.find<AuthController>();
  final Logger _logger = Logger();

  final RxList<ChatConversation> conversations = <ChatConversation>[].obs;
  final RxList<ChatMessage> currentMessages = <ChatMessage>[].obs;
  final RxBool isLoadingConversations = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreMessages = true.obs;
  final RxString activeConversationId = ''.obs;
  final RxBool isUpdatingStatus = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Use microtask to ensure this doesn't run during a build phase
    Future.microtask(() => fetchConversations());
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
      _handleStatusUpdate(data);
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

  String getNormalizedConversationId(String id1, String id2) {
    if (id1.isEmpty || id2.isEmpty) return '';
    final List<String> ids = [id1, id2];
    ids.sort();
    return ids.join('-');
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
      hasMoreMessages.value = true;
      currentMessages.clear();

      // Join new room
      _socketService.emit('conversation:join', convoId);

      // Production API Call
      final response = await _apiService.getRequest(
        '${AppUrls.messagesByConversation}$convoId/messages',
        query: {'limit': '30'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.body['data'] ?? [];
        currentMessages.value = data
            .map((json) => ChatMessage.fromJson(json))
            .toList();

        if (data.length < 30) {
          hasMoreMessages.value = false;
        }

        // Mark as read locally and on server
        _socketService.emit('message:read', {'conversationId': convoId});
      }
    } catch (e) {
      _logger.e('Error fetching messages: $e');
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<void> loadMoreMessages() async {
    if (isLoadingMore.value || !hasMoreMessages.value || activeConversationId.isEmpty) return;

    try {
      isLoadingMore.value = true;
      final String convoId = activeConversationId.value;
      final String? before = currentMessages.isNotEmpty ? currentMessages.last.timestamp?.toIso8601String() : null;

      final response = await _apiService.getRequest(
        '${AppUrls.messagesByConversation}$convoId/messages',
        query: {
          'limit': '30',
          if (before != null) 'before': before,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.body['data'] ?? [];
        final List<ChatMessage> olderMessages = data
            .map((json) => ChatMessage.fromJson(json))
            .toList();

        if (olderMessages.isEmpty || olderMessages.length < 30) {
          hasMoreMessages.value = false;
        }

        if (olderMessages.isNotEmpty) {
          currentMessages.addAll(olderMessages);
        }
      }
    } catch (e) {
      _logger.e('Error loading more messages: $e');
    } finally {
      isLoadingMore.value = false;
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

    currentMessages.insert(0, optimisticMsg);

    // Emit via socket
    _socketService.emit('message:send', {
      'conversationId': activeConversationId.value,
      'content': content,
      'tempId': tempId,
      'receiverId': receiverId,
    });
  }

  Future<String?> acceptRequest(String conversationId, {String? bookingId}) async {
    try {
      isUpdatingStatus.value = true;
      final response = await _apiService.postRequest(
        '${AppUrls.acceptChatRequest}$conversationId/accept',
        {'bookingId': bookingId},
      );
      if (response.statusCode == 200) {
        final String? generalId = response.body['data']?['conversationId'] ?? conversationId;
        
        // Update local state immediately
        final index = conversations.indexWhere((c) => c.conversationId == conversationId);
        if (index != -1) {
          final old = conversations[index];
          conversations[index] = ChatConversation(
            id: old.id,
            conversationId: generalId ?? conversationId,
            otherUser: old.otherUser,
            lastMessage: old.lastMessage,
            date: old.date,
            unread: old.unread,
            status: 'request-accepted',
            senderId: old.senderId,
            booking: old.booking,
            pinned: old.pinned,
            label: old.label,
          );
          conversations.refresh();
        }

        _handleStatusUpdate({
          'conversationId': conversationId,
          'status': 'request-accepted',
          'generalConversationId': generalId,
        });
        
        return generalId;
      }
      return null;
    } catch (e) {
      _logger.e('Error accepting request: $e');
      return null;
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  Future<bool> declineRequest(String conversationId, {String? bookingId}) async {
    try {
      isUpdatingStatus.value = true;
      final response = await _apiService.postRequest(
        '${AppUrls.declineChatRequest}$conversationId/decline',
        {'bookingId': bookingId},
      );
      if (response.statusCode == 200) {
        _handleStatusUpdate({
          'conversationId': conversationId,
          'status': 'request-declined',
        });
        await fetchConversations();
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Error declining request: $e');
      return false;
    } finally {
      isUpdatingStatus.value = false;
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
        currentMessages.insert(0, message);
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

  void openBookingChat({
    required String bookingId,
    required String otherId,
    required String otherName,
    required String otherImage,
  }) {
    final myId = Get.find<ProfileController>().id;
    if (myId.isEmpty) return;

    final sorted = [myId, otherId]..sort();
    final conversationId = "${sorted[0]}-${sorted[1]}";

    Get.to(() => SingleChatView(
          name: otherName,
          image: otherImage,
          conversationId: conversationId,
          otherId: otherId,
        ));
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
        currentMessages.insert(0, message);
      }
    }
    fetchConversations(); // Sync last message in sidebar
  }

  void _handleStatusUpdate(Map<String, dynamic> data) {
    final String conversationId = data['conversationId'];
    final String status = data['status'];
    final String? generalId = data['generalConversationId'];

    // Update conversation list item in-place
    final convoIndex = conversations.indexWhere((c) => c.conversationId == conversationId);
    if (convoIndex != -1) {
      final old = conversations[convoIndex];
      conversations[convoIndex] = ChatConversation(
        id: old.id,
        conversationId: generalId ?? old.conversationId,
        otherUser: old.otherUser,
        lastMessage: old.lastMessage,
        date: old.date,
        unread: old.unread,
        status: status,
        senderId: old.senderId,
        booking: old.booking,
        pinned: old.pinned,
        label: old.label,
      );
      conversations.refresh();
    }

    if (conversationId == activeConversationId.value) {
      if (generalId != null) {
        activeConversationId.value = generalId;
      }
      // 2. Update local messages if they share this status
      final updatedMessages = currentMessages
          .map(
            (m) => ChatMessage(
              id: m.id,
              conversationId: generalId ?? m.conversationId,
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

    // Refresh bookings to reflect new status (confirmed/rejected)
    if (Get.isRegistered<BookingController>()) {
      final bc = Get.find<BookingController>();
      bc.fetchBookings(type: 'received');
      bc.fetchBookings(type: 'sent');
    }
  }
}

