import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/models/message_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/services/socket_service.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
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
        conversations.value = data.map((json) => ChatConversation.fromJson(json)).toList();
      }

      // Add dummy data for UI review if list is empty or for local testing
      if (conversations.isEmpty) {
        conversations.addAll([
          ChatConversation(
            id: '1',
            conversationId: 'c1',
            lastMessage: 'Thanks so much, happy with that.',
            date: DateTime.now().subtract(const Duration(minutes: 2)),
            unread: 1,
            otherUser: ChatOtherUser(
              id: 'u1',
              name: 'Lana Steiner',
              avatar: 'https://i.pravatar.cc/150?u=lana',
            ),
          ),
          ChatConversation(
            id: '2',
            conversationId: 'c2',
            lastMessage: 'Got you a coffee',
            date: DateTime.now().subtract(const Duration(minutes: 2)),
            unread: 0,
            otherUser: ChatOtherUser(
              id: 'u2',
              name: 'Demi Wilkinson',
              avatar: 'https://i.pravatar.cc/150?u=demi',
            ),
          ),
          ChatConversation(
            id: '3',
            conversationId: 'c3',
            lastMessage: 'Great to see you again!',
            date: DateTime.now().subtract(const Duration(hours: 3)),
            unread: 0,
            otherUser: ChatOtherUser(
              id: 'u3',
              name: 'Candice Wu',
              avatar: 'https://i.pravatar.cc/150?u=candice',
            ),
          ),
          ChatConversation(
            id: '4',
            conversationId: 'c4',
            lastMessage: 'We should ask Oli about this...',
            date: DateTime.now().subtract(const Duration(hours: 6)),
            unread: 0,
            otherUser: ChatOtherUser(
              id: 'u4',
              name: 'Natali Craig',
              avatar: 'https://i.pravatar.cc/150?u=natali',
            ),
          ),
          ChatConversation(
            id: '5',
            conversationId: 'c5',
            lastMessage: 'Okay, see you then.',
            date: DateTime.now().subtract(const Duration(hours: 12)),
            unread: 0,
            otherUser: ChatOtherUser(
              id: 'u5',
              name: 'Drew Cano',
              avatar: 'https://i.pravatar.cc/150?u=drew',
            ),
          ),
          ChatConversation(
            id: 'r1',
            conversationId: 'cr1',
            status: 'request-pending',
            lastMessage: 'I am interested in your horse booking.',
            date: DateTime.now().subtract(const Duration(hours: 1)),
            otherUser: ChatOtherUser(
              id: 'ur1',
              name: 'Mark Lee',
              avatar: 'https://i.pravatar.cc/150?u=mark1',
              role: 'Professional Horse Trainer',
            ),
          ),
          ChatConversation(
            id: 'r2',
            conversationId: 'cr2',
            status: 'request-pending',
            lastMessage: 'Can we schedule a viewing for Starfire?',
            date: DateTime.now().subtract(const Duration(hours: 2)),
            otherUser: ChatOtherUser(
              id: 'ur2',
              name: 'Mark Lee',
              avatar: 'https://i.pravatar.cc/150?u=mark2',
              role: 'Professional Horse Trainer',
            ),
          ),
        ]);
      }
    } catch (e) {
      _logger.e('Error fetching conversations: $e');
    } finally {
      isLoadingConversations.value = false;
    }
  }

  Future<void> fetchMessages(String convoId) async {
    try {
      activeConversationId.value = convoId;
      isLoadingMessages.value = true;
      currentMessages.clear();

      // INJECT DUMMY MESSAGES FOR LANA STEINER (c1)
      if (convoId == 'c1') {
        currentMessages.addAll([
          ChatMessage(
            id: 'm1',
            conversationId: convoId,
            content: 'Hi! Just checking if the bay 7yr jumper is still available to try this week at WEC?',
            senderId: 'lana',
            senderName: 'Lana Steiner',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            read: true,
          ),
          ChatMessage(
            id: 'm2',
            conversationId: convoId,
            content: 'Yes, he is. He\'ll be there through Sunday.',
            senderId: 'me',
            senderName: 'You',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            read: true,
          ),
          ChatMessage(
            id: 'm3',
            conversationId: convoId,
            content: 'Great — what height is he comfortable at right now?',
            senderId: 'lana',
            senderName: 'Lana Steiner',
            timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
            read: true,
          ),
          ChatMessage(
            id: 'm4',
            conversationId: convoId,
            content: 'Currently showing 1.20m but schooling higher at home. Very straight forward.',
            senderId: 'me',
            senderName: 'You',
            timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
            read: true,
          ),
          ChatMessage(
            id: 'm5',
            conversationId: convoId,
            content: 'Perfect. I may have a Jr rider who could try him Friday.',
            senderId: 'lana',
            senderName: 'Lana Steiner',
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            read: true,
          ),
          ChatMessage(
            id: 'm6',
            conversationId: convoId,
            content: 'That works. Let me know what time and I\'ll coordinate.',
            senderId: 'me',
            senderName: 'You',
            timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
            read: true,
          ),
        ]);
        isLoadingMessages.value = false;
        _socketService.emit('message:read', {'conversationId': convoId});
        return;
      }

      // GENERIC DUMMY MESSAGES FOR OTHER CONVERSATIONS
      if (convoId.startsWith('c')) {
        currentMessages.addAll([
          ChatMessage(
            id: 'm1_${convoId}',
            conversationId: convoId,
            content: 'Hello! How are things going with the training?',
            senderId: 'other',
            senderName: 'Other User',
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
            read: true,
          ),
          ChatMessage(
            id: 'm2_${convoId}',
            conversationId: convoId,
            content: 'Everything is going great, thank you for asking!',
            senderId: 'me',
            senderName: 'You',
            timestamp: DateTime.now().subtract(const Duration(hours: 4)),
            read: true,
          ),
          ChatMessage(
            id: 'm3_${convoId}',
            conversationId: convoId,
            content: 'Glad to hear it. Let me know if you need anything else.',
            senderId: 'other',
            senderName: 'Other User',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            read: true,
          ),
        ]);
        isLoadingMessages.value = false;
        _socketService.emit('message:read', {'conversationId': convoId});
        return;
      }

      final response = await _apiService.getRequest('${AppUrls.messagesByConversation}$convoId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.body['data'] ?? [];
        currentMessages.value = data.map((json) => ChatMessage.fromJson(json)).toList();
        
        // Mark as read locally and on server
        _socketService.emit('message:read', {'conversationId': convoId});
      }
    } catch (e) {
      _logger.e('Error fetching messages: $e');
    } finally {
      isLoadingMessages.value = false;
    }
  }

  void sendMessage(String content, {String? receiverId}) {
    if (content.trim().isEmpty || activeConversationId.isEmpty) return;

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

  // ─── INTERNAL HANDLERS ───────────────────────────────────────────────────────

  void _handleIncomingMessage(ChatMessage message) {
    if (message.conversationId == activeConversationId.value) {
      currentMessages.add(message);
      _socketService.emit('message:read', {'conversationId': message.conversationId});
    }
    
    // Update conversation list item
    final index = conversations.indexWhere((c) => c.conversationId == message.conversationId);
    if (index != -1) {
      // Move to top and update last message
      // Note: In a real app, you'd likely want to refresh the conversation list or update the object
      fetchConversations(); // Simplest way to keep sync for now
    } else {
      fetchConversations(); // New conversation appeared
    }
  }

  void _handleSentConfirmation(String tempId, ChatMessage message) {
    final index = currentMessages.indexWhere((m) => m.id == tempId);
    if (index != -1) {
      currentMessages[index] = message;
    }
    fetchConversations(); // Sync last message in sidebar
  }

  void _handleStatusUpdate(String conversationId, String status) {
    if (conversationId == activeConversationId.value) {
      // Update local messages if they share this status
      final updatedMessages = currentMessages.map((m) => ChatMessage(
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
      )).toList();
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
