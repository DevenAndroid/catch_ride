import 'dart:async';
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

  // Timer? _refreshTimer;

  int get totalUnreadCount {
    return conversations.fold(0, (sum, convo) => sum + convo.unread);
  }

  @override
  void onInit() {
    super.onInit();
    // Use microtask to ensure this doesn't run during a build phase
    Future.microtask(() => fetchConversations());
    _socketService.onRefresh(_setupSocketListeners);
    _setupSocketListeners();
    // Periodic background refresh as a safety net for missed socket events
    // _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
    //   fetchConversations(quiet: true);
    // });
  }

  void clearData() {
    conversations.clear();
    currentMessages.clear();
    activeConversationId.value = '';
    isLoadingConversations.value = false;
    isLoadingMessages.value = false;
    isLoadingMore.value = false;
    hasMoreMessages.value = true;
    _logger.i('ChatController: Data cleared.');
  }

  @override
  void onClose() {
    // _refreshTimer?.cancel();
    super.onClose();
  }

  void _setupSocketListeners() {
    if (!_socketService.isInitialized) {
      _logger.w('ChatController: Socket not initialized yet. Skipping listener setup.');
      return;
    }

    // 0. Remove old listeners before re-registering (Fix #2)
    _socketService.socket.off('message:received');
    _socketService.socket.off('message:sent');
    _socketService.socket.off('conversation:status:updated');

    // 1. Message Received
    _socketService.socket.on('message:received', (data) {
      _logger.d('📩 ChatController: Received message:received event');
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

    // 4. Refresh conversations list (Sync inbox for new user session)
    fetchConversations(quiet: true);
  }

  // ─── API ACTIONS ─────────────────────────────────────────────────────────────

  Future<void> fetchConversations({bool quiet = false}) async {
    try {
      if (!quiet) isLoadingConversations.value = true;
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
      
      // Clear but KEEP optimistic/temp messages (Fix #1)
      currentMessages.removeWhere((m) => !m.id.startsWith('temp-'));

      // Join new room
      _socketService.emit('conversation:join', convoId);

      // Production API Call
      final response = await _apiService.getRequest(
        '${AppUrls.messagesByConversation}$convoId/messages',
        query: {'limit': '30'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.body['data'] ?? [];
        final List<ChatMessage> newMessages = data
            .map((json) => ChatMessage.fromJson(json))
            .toList();

        // Merge API data with existing temp messages (Fix #1)
        for (var msg in newMessages) {
          if (!currentMessages.any((m) => m.id == msg.id)) {
            currentMessages.add(msg);
          }
        }
        
        // Sort to ensure temp messages are at the top if they are newest
        currentMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        if (data.length < 30) {
          hasMoreMessages.value = false;
        }

        // Mark as read locally and on server
        _socketService.emit('message:read', {'conversationId': convoId});
        
        // --- LOCAL UNREAD SYNC (Fix #4) ---
        final index = conversations.indexWhere((c) => c.conversationId == convoId);
        if (index != -1) {
          final old = conversations[index];
          conversations[index] = ChatConversation(
            id: old.id,
            conversationId: old.conversationId,
            otherUser: old.otherUser,
            lastMessage: old.lastMessage,
            date: old.date,
            unread: 0, // Set to 0 instantly
            status: old.status,
            senderId: old.senderId,
            booking: old.booking,
            pinned: old.pinned,
            label: old.label,
          );
          conversations.refresh();
        }
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
          // Filter out any messages that might already exist (Fix #3)
          final List<ChatMessage> uniqueOlder = olderMessages
              .where((newMsg) => !currentMessages.any((oldMsg) => oldMsg.id == newMsg.id))
              .toList();
          
          if (uniqueOlder.isNotEmpty) {
            currentMessages.addAll(uniqueOlder);
            // Re-sort to maintain order if something arrived out of sync
            currentMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          }
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

    // Resolve receiverId if caller didn't provide it.
    // If receiverId is wrong/missing, backend can't persist the message and it will "disappear" on refresh.
    String? resolvedReceiverId = receiverId;
    if (resolvedReceiverId == null || resolvedReceiverId.isEmpty) {
      final convo = conversations.firstWhereOrNull(
        (c) => c.conversationId == activeConversationId.value,
      );
      resolvedReceiverId = convo?.otherUser?.id;
    }
    if ((resolvedReceiverId == null || resolvedReceiverId.isEmpty) &&
        activeConversationId.value.contains('-')) {
      final parts = activeConversationId.value.split('-');
      final me = _authController.currentUser.value?.id ?? '';
      if (parts.length >= 2 && me.isNotEmpty) {
        resolvedReceiverId = parts[0] == me ? parts[1] : parts[0];
      }
    }
    if (resolvedReceiverId == null || resolvedReceiverId.isEmpty) {
      Get.snackbar(
        'Error',
        'Unable to send message right now. Please reopen the chat and try again.',
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
      'receiverId': resolvedReceiverId,
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
    _logger.d('📥 Handling incoming message for convo: ${message.conversationId}');
    _logger.d('📱 Active conversation: ${activeConversationId.value}');

    final String currentUserId = _authController.currentUser.value?.id ?? '';
    final bool isMe = message.senderId == currentUserId && currentUserId.isNotEmpty;

    _logger.d('👤 ChatController ID Check: Msg Sender: ${message.senderId} | Current User: $currentUserId | isMe: $isMe');
    _logger.d('💬 Content: ${message.content}');

    if (message.conversationId == activeConversationId.value) {
      _logger.d('✅ Message matches active conversation. Inserting into list.');
      // 1. Check if ID already exists
      bool exists = currentMessages.any((m) => m.id == message.id);

      // 2. For the SENDER: check for matching optimistic message
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

      // --- LOCAL UNREAD SYNC (Fix #4) ---
      // If we are currently in this chat, keep unread at 0 locally
      final convoIndex = conversations.indexWhere((c) => c.conversationId == message.conversationId);
      if (convoIndex != -1) {
        final old = conversations[convoIndex];
        conversations[convoIndex] = ChatConversation(
          id: old.id,
          conversationId: old.conversationId,
          otherUser: old.otherUser,
          lastMessage: message.content,
          date: message.timestamp,
          unread: 0, 
          status: message.status ?? old.status,
          senderId: message.senderId,
          booking: old.booking,
          pinned: old.pinned,
          label: old.label,
        );
        conversations.refresh();
        return; // Skip the standard increment logic below
      }
    } else if (activeConversationId.isNotEmpty) {
      // HANDLE ID TRANSITION (e.g. from Temp/Vendor ID to Normalized User ID)
      // We check if the incoming message's participants overlap with our current active chat.
      final activeParts = activeConversationId.value.split('-');
      final msgParts = message.conversationId.split('-');
      
      bool isSameConversation = false;
      if (activeParts.length >= 2 && msgParts.length >= 2) {
        // If both IDs involve the same two people (even if one ID is a profile ID and other is User ID)
        // We check if the sender of this message is one of the people we are talking to.
        final String me = currentUserId;
        final String otherInActive = activeParts[0] == me ? activeParts[1] : activeParts[0];
        
        if (msgParts.contains(me) && msgParts.contains(message.senderId)) {
          // If the message is from the person we are currently talking to (or ourselves)
          isSameConversation = true;
        }
      }

      if (isSameConversation) {
        _logger.i('🔄 Real-time ID transition: ${activeConversationId.value} -> ${message.conversationId}');
        activeConversationId.value = message.conversationId;
        currentMessages.insert(0, message);
        
        _socketService.emit('message:read', {
          'conversationId': message.conversationId,
        });
      } else {
        // --- BACKGROUND NOTIFICATION (Fix #6) ---
        // If we are on a different screen or in a different chat, show a notification
        if (!isMe) {
          // Get.snackbar(
          //   message.senderName,
          //   message.content,
          //   snackPosition: SnackPosition.TOP,
          //   backgroundColor: AppColors.primary,
          //   colorText: Colors.white,
          //   duration: const Duration(seconds: 4),
          //   onTap: (_) {
          //     // Open this chat when tapped
          //     openBookingChat(
          //       bookingId: message.conversationId,
          //       otherId: message.senderId,
          //       otherName: message.senderName,
          //       otherImage: message.senderImage ?? '',
          //     );
          //   },
          // );
        }
      }
    } else {
      // --- BACKGROUND NOTIFICATION (Fix #6) ---
      // If no active conversation is open at all, show notification
      if (!isMe) {
        // Get.snackbar(
        //   message.senderName,
        //   message.content,
        //   snackPosition: SnackPosition.TOP,
        //   backgroundColor: AppColors.primary,
        //   colorText: Colors.white,
        //   duration: const Duration(seconds: 4),
        //   onTap: (_) {
        //     openBookingChat(
        //       bookingId: message.conversationId,
        //       otherId: message.senderId,
        //       otherName: message.senderName,
        //       otherImage: message.senderImage ?? '',
        //     );
        //   },
        // );
      }
    }

    // --- REAL-TIME INBOX UPDATE (In-place) ---
    final index = conversations.indexWhere(
      (c) => c.conversationId == message.conversationId,
    );

    if (index != -1) {
      // Update existing conversation item
      final old = conversations.removeAt(index);
      final updated = ChatConversation(
        id: old.id,
        conversationId: old.conversationId,
        otherUser: old.otherUser,
        lastMessage: message.content,
        date: message.timestamp,
        unread: isMe ? old.unread : (old.unread + 1),
        status: message.status ?? old.status,
        senderId: message.senderId,
        booking: old.booking,
        pinned: old.pinned,
        label: old.label,
      );
      
      // Insert at the top
      _logger.d('🆕 Updating conversation list item for ${message.conversationId}');
      conversations.insert(0, updated);
      conversations.refresh();
    } else {
      _logger.d('❓ Conversation not found in list. Fetching all.');
      // New conversation appeared - if it's the first message, we might need 
      // one refresh to get the full "otherUser" object details from server
      fetchConversations(quiet: true);
    }
  }

  void openBookingChat({
    required String bookingId,
    required String otherId,
    required String otherName,
    required String otherImage,
    String? myTeamId,
  }) {
    // 1. Try to find an existing conversation for this specific booking
    // This is the most accurate way as it works for both Trainer and Barn Manager
    final existingConvo = conversations.firstWhereOrNull(
      (c) =>
          c.booking?.id == bookingId ||
          c.id == bookingId ||
          c.conversationId == bookingId,
    );

    if (existingConvo != null) {
      Get.to(() => SingleChatView(
            name: otherName,
            image: otherImage,
            conversationId: existingConvo.conversationId,
            otherId: otherId,
          ));
      return;
    }

    // 1.2 Fallback: If no specific booking thread found, try to find ANY existing general chat 
    // with this specific user in our current inbox list.
    final existingWithUser = conversations.firstWhereOrNull(
      (c) => c.otherUser?.id == otherId || c.otherUser?.trainerId == otherId || c.otherUser?.vendorId == otherId,
    );
    if (existingWithUser != null) {
      Get.to(() => SingleChatView(
            name: otherName,
            image: otherImage,
            conversationId: existingWithUser.conversationId,
            otherId: otherId,
          ));
      return;
    }

    // 2. Identify identities
    final profile = Get.find<ProfileController>();
    // Use the explicitly provided team ID (Trainer User ID) if available, otherwise fallback to our own personal ID.
    final String myPersonalId = (myTeamId != null && myTeamId.isNotEmpty) ? myTeamId : profile.id;

    // 3. Try fallback to General Chat - First try personal identity
    final personalSorted = [myPersonalId, otherId]..sort();
    final personalConvoId = "${personalSorted[0]}-${personalSorted[1]}";
    
    final existingPersonal = conversations.firstWhereOrNull(
      (c) => c.conversationId == personalConvoId,
    );

    if (existingPersonal != null) {
      Get.to(() => SingleChatView(
            name: otherName,
            image: otherImage,
            conversationId: existingPersonal.conversationId,
            otherId: otherId,
          ));
      return;
    }

    // 5. Final fallback - Create new personal thread
    Get.to(() => SingleChatView(
          name: otherName,
          image: otherImage,
          conversationId: personalConvoId,
          otherId: otherId,
        ));
  }

  void _handleSentConfirmation(String tempId, ChatMessage message) {
    // 1. Update activeConversationId if the backend returned a normalized one (Fix #3)
    final String currentActiveId = activeConversationId.value;
    if (currentActiveId == tempId || 
        currentActiveId == message.conversationId || 
        currentActiveId.contains(message.conversationId.split('-')[0]) ||
        currentActiveId.contains(message.conversationId.split('-')[1])) {
      
      if (currentActiveId != message.conversationId) {
        _logger.i('🔄 Syncing activeConversationId to normalized ID: ${message.conversationId}');
        activeConversationId.value = message.conversationId;
      }
    }

    // 2. Remove any other instances of this real ID that might have arrived before the confirmation
    currentMessages.removeWhere((m) => m.id == message.id && m.id != tempId);

    // 3. Find and replace the optimistic message
    final index = currentMessages.indexWhere((m) => m.id == tempId);
    if (index != -1) {
      currentMessages[index] = message;
    } else {
      // If the optimistic message is gone but we didn't find the real ID yet, add it
      if (!currentMessages.any((m) => m.id == message.id)) {
        currentMessages.insert(0, message);
      }
    }
    fetchConversations(quiet: true); // Sync last message in sidebar (quiet to avoid flicker)
  }

  void _handleStatusUpdate(Map<String, dynamic> data) {
    final String conversationId = data['conversationId'];
    final String status = data['status'];
    final String? generalId = data['generalConversationId'] ?? data['normalizedId'];

    // Update conversation list item in-place
    final convoIndex = conversations.indexWhere((c) => c.conversationId == conversationId);
    if (convoIndex != -1) {
      final updated = ChatConversation(
        id: conversations[convoIndex].id,
        conversationId: generalId ?? conversations[convoIndex].conversationId,
        lastMessage: conversations[convoIndex].lastMessage,
        date: conversations[convoIndex].date,
        unread: conversations[convoIndex].unread,
        status: status,
        otherUser: conversations[convoIndex].otherUser,
        senderId: conversations[convoIndex].senderId,
        booking: conversations[convoIndex].booking,
        pinned: conversations[convoIndex].pinned,
        label: conversations[convoIndex].label,
      );
      conversations[convoIndex] = updated;
      conversations.refresh();
    } else {
      // If we receive a status update for a conversation we don't know about yet,
      // it's likely a new request or a first-time message. Fetch the list.
      fetchConversations(quiet: true);
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
              senderImage: m.senderImage,
              content: m.content,
              timestamp: m.timestamp,
              read: m.read,
              flagged: m.flagged,
              status: status,
              type: m.type,
              bookingId: m.bookingId,
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
      bc.refreshPendingBookingCounts();
    }
  }
}

