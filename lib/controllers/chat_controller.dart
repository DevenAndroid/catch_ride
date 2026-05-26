import 'dart:async';
import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/controllers/barn_manager/barn_manager_booking_controller.dart';
import 'package:catch_ride/models/booking_model.dart';
import 'package:catch_ride/models/message_model.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/services/notification_service.dart';
import 'package:catch_ride/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../constant/app_colors.dart';
import '../view/barn_manager/chats/barn_manager_single_chat_view.dart';
import '../view/trainer/chats/single_chat_view.dart';
import 'booking_controller.dart';
import 'profile_controller.dart';
import '../utils/booking_controller_lookup.dart';

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

  final Map<String, String?> _bookingNotesCache = {};

  /// Debounced refresh of bottom-nav pending booking count when inbox data changes.
  Timer? _pendingBookingBadgeDebounce;

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

  /// Notes for the booking tied to a chat card (cached; same value for sender and receiver).
  Future<String?> bookingNotesForId(
    String? bookingId, {
    String? fromMessage,
    String? conversationId,
  }) async {
    final fromMsg = fromMessage?.trim();
    if (fromMsg != null && fromMsg.isNotEmpty) return fromMsg;

    if (bookingId == null || bookingId.isEmpty) return null;

    if (_bookingNotesCache.containsKey(bookingId)) {
      return _bookingNotesCache[bookingId];
    }

    if (conversationId != null && conversationId.isNotEmpty) {
      final convo = conversations.firstWhereOrNull(
        (c) => c.conversationId == conversationId,
      );
      final convoBookingId = convo?.booking?.id;
      final convoNotes = convo?.booking?.notes?.trim();
      if (convoBookingId == bookingId &&
          convoNotes != null &&
          convoNotes.isNotEmpty) {
        _bookingNotesCache[bookingId] = convoNotes;
        return convoNotes;
      }
    }

    try {
      final response = await _apiService.getRequest('/bookings/$bookingId');
      if (response.statusCode == 200 && response.body['data'] != null) {
        final notes = BookingModel.fromJson(response.body['data']).notes?.trim();
        final value = (notes != null && notes.isNotEmpty) ? notes : null;
        _bookingNotesCache[bookingId] = value;
        return value;
      }
    } catch (e) {
      _logger.w('bookingNotesForId failed for $bookingId: $e');
    }

    _bookingNotesCache[bookingId] = null;
    return null;
  }

  void clearData() {
    conversations.clear();
    currentMessages.clear();
    _bookingNotesCache.clear();
    activeConversationId.value = '';
    isLoadingConversations.value = false;
    isLoadingMessages.value = false;
    isLoadingMore.value = false;
    hasMoreMessages.value = true;
    _logger.i('ChatController: Data cleared.');
  }

  @override
  void onClose() {
    _pendingBookingBadgeDebounce?.cancel();
    // _refreshTimer?.cancel();
    super.onClose();
  }

  /// Barn manager registers [BarnManagerBookingController]; trainer/vendor use [BookingController].
  BookingController? _tryFindBookingController() {
    if (Get.isRegistered<BarnManagerBookingController>()) {
      return Get.find<BarnManagerBookingController>();
    }
    if (Get.isRegistered<BookingController>()) {
      return Get.find<BookingController>();
    }
    return null;
  }

  void _schedulePendingBookingBadgeSync() {
    _pendingBookingBadgeDebounce?.cancel();
    _pendingBookingBadgeDebounce = Timer(const Duration(milliseconds: 350), () {
      _pendingBookingBadgeDebounce = null;
      _syncPendingBookingBadgeNow();
    });
  }

  void _syncPendingBookingBadgeNow() {
    try {
      final bc = _tryFindBookingController();
      if (bc != null) {
        bc.refreshPendingBookingCounts();
      }
    } catch (e) {
      _logger.w('ChatController: pending booking badge sync skipped: $e');
    }
  }

  void _setConversationUnread(String conversationId, int unread) {
    final index = conversations.indexWhere(
      (c) => c.conversationId == conversationId,
    );
    if (index == -1) return;

    final old = conversations[index];
    if (old.unread == unread) return;

    conversations[index] = ChatConversation(
      id: old.id,
      conversationId: old.conversationId,
      otherUser: old.otherUser,
      lastMessage: old.lastMessage,
      date: old.date,
      unread: unread,
      status: old.status,
      senderId: old.senderId,
      booking: old.booking,
      pinned: old.pinned,
      label: old.label,
    );
    conversations.refresh();
  }

  /// While a chat is open, treat it as read for badge/inbox even if the server count lags.
  void _syncUnreadForOpenChat() {
    if (activeConversationId.isEmpty) return;
    _setConversationUnread(activeConversationId.value, 0);
  }

  /// App icon badge = unread chat messages only (not in-app notification list).
  void _syncAppIconBadge() {
    try {
      if (Get.isRegistered<NotificationService>()) {
        Get.find<NotificationService>().updateBadge(totalUnreadCount);
      }
    } catch (e) {
      _logger.w('ChatController: app icon badge sync skipped: $e');
    }
  }

  void _setupSocketListeners() {
    if (!_socketService.isInitialized) {
      _logger.w('ChatController: Socket not initialized yet. Skipping listener setup.');
      return;
    }

    // 0. Remove old listeners before re-registering (Fix #2)
    _socketService.socket.off('message:received');
    _socketService.socket.off('message:sent');
    _socketService.socket.off('message:error');
    _socketService.socket.off('conversation:status:updated');
    _socketService.socket.off('conversations:refresh');
    _socketService.socket.off('bookings:pending-count:refresh');

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

    _socketService.socket.on('message:error', (data) {
      final tempId = data['tempId']?.toString();
      final errMsg = data['message']?.toString() ??
          'You do not have access to this conversation until a booking is confirmed.';
      if (tempId != null && tempId.isNotEmpty) {
        currentMessages.removeWhere((m) => m.id == tempId);
      }
      Get.snackbar(
        'Message not sent',
        errMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
      );
    });

    // 3. Status Updated
    _socketService.socket.on('conversation:status:updated', (data) {
      _handleStatusUpdate(data);
    });

    // 4. Barn manager granted access to a booking chat (refresh inbox)
    _socketService.socket.on('conversations:refresh', (_) {
      fetchConversations(quiet: true);
    });

    // 5. Barn manager: pending received booking count (no chat access yet)
    _socketService.socket.on('bookings:pending-count:refresh', (_) {
      _syncPendingBookingBadgeNow();
    });

    // 6. Refresh conversations list (Sync inbox for new user session)
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
        _dedupeConversationsByOtherUser();
        _syncUnreadForOpenChat();
        _schedulePendingBookingBadgeSync();
        _syncAppIconBadge();
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

  /// True when two thread ids are the same chat (e.g. trainer–client vs barn–client).
  bool _isSameChatThread(String activeId, String messageId, String myUserId) {
    if (activeId.isEmpty || messageId.isEmpty) return false;
    if (activeId == messageId) return true;
    final activeParts = activeId.split('-').where((p) => p.isNotEmpty).toSet();
    final msgParts = messageId.split('-').where((p) => p.isNotEmpty).toSet();
    if (activeParts.length < 2 || msgParts.length < 2) return false;
    final shared = activeParts.intersection(msgParts);
    // Same external party, different team member id in the thread key (bm vs trainer)
    if (shared.isNotEmpty &&
        activeParts.difference(msgParts).length == 1 &&
        msgParts.difference(activeParts).length == 1) {
      return true;
    }
    if (shared.contains(myUserId) && shared.length >= 2) return true;
    return false;
  }

  void _syncActiveConversationRoom(String conversationId) {
    final previous = activeConversationId.value;
    if (previous == conversationId) return;
    if (previous.isNotEmpty) {
      _socketService.emit('conversation:leave', previous);
    }
    activeConversationId.value = conversationId;
    if (conversationId.isNotEmpty) {
      _socketService.emit('conversation:join', conversationId);
    }
  }

  /// One inbox row per counterparty (merges trainer–client and barn–client duplicates).
  void _dedupeConversationsByOtherUser() {
    if (conversations.isEmpty) return;
    final Map<String, ChatConversation> bestByOther = {};
    for (final c in conversations) {
      final key = c.otherUser?.id ?? c.conversationId;
      if (key.isEmpty) continue;
      final existing = bestByOther[key];
      final cDate = c.date ?? DateTime.fromMillisecondsSinceEpoch(0);
      final exDate = existing?.date ?? DateTime.fromMillisecondsSinceEpoch(0);
      if (existing == null || cDate.isAfter(exDate)) {
        bestByOther[key] = c;
      }
    }
    if (bestByOther.length == conversations.length) return;
    final merged = bestByOther.values.toList()
      ..sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
    conversations.value = merged;
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

        if (newMessages.isNotEmpty) {
          final canonical = newMessages.first.conversationId;
          if (canonical.isNotEmpty && canonical != convoId) {
            _syncActiveConversationRoom(canonical);
          }
        }

        // Mark as read locally and on server
        _socketService.emit('message:read', {
          'conversationId': activeConversationId.value,
        });

        _setConversationUnread(convoId, 0);
        _syncAppIconBadge();
      } else if (response.statusCode == 403) {
        final body = response.body;
        final errMsg = body is Map
            ? (body['message']?.toString() ??
                'You do not have access to this conversation until a booking is confirmed.')
            : 'You do not have access to this conversation until a booking is confirmed.';
        Get.snackbar(
          'Chat unavailable',
          errMsg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
        );
        if (Get.key.currentState?.canPop() ?? false) Get.back();
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

    final bool sameThread = message.conversationId == activeConversationId.value ||
        _isSameChatThread(
          activeConversationId.value,
          message.conversationId,
          currentUserId,
        );

    if (sameThread) {
      if (activeConversationId.value != message.conversationId) {
        _syncActiveConversationRoom(message.conversationId);
      }
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

      final convoIndex = conversations.indexWhere(
        (c) => c.conversationId == message.conversationId,
      );
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
        _schedulePendingBookingBadgeSync();
        _syncAppIconBadge();
        return;
      }
    } else if (activeConversationId.isNotEmpty) {
      final bool isSameConversation = _isSameChatThread(
        activeConversationId.value,
        message.conversationId,
        currentUserId,
      );

      if (isSameConversation) {
        _logger.i(
          '🔄 Real-time ID transition: ${activeConversationId.value} -> ${message.conversationId}',
        );
        _syncActiveConversationRoom(message.conversationId);
        currentMessages.insert(0, message);
        
        _socketService.emit('message:read', {
          'conversationId': message.conversationId,
        });
        _setConversationUnread(message.conversationId, 0);
        _syncAppIconBadge();
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
      _schedulePendingBookingBadgeSync();
      _syncAppIconBadge();
    } else {
      _logger.d('❓ Conversation not found in list. Fetching all.');
      // New conversation appeared - if it's the first message, we might need 
      // one refresh to get the full "otherUser" object details from server
      fetchConversations(quiet: true);
    }
  }

  bool get _usesBarnManagerChat {
    final role = _authController.currentUser.value?.role ??
        Get.put(ProfileController()).user.value?.role ??
        '';
    return role == 'barn_manager';
  }

  /// Opens the role-appropriate single-chat screen (trainer vs barn manager UI).
  Future<void> openChatThread({
    required String name,
    required String image,
    required String conversationId,
    String? otherId,
    bool readOnly = false,
    bool prefetchMessages = true,
  }) async {
    if (prefetchMessages && conversationId.isNotEmpty) {
      await fetchMessages(conversationId);
      await fetchConversations(quiet: true);
    }

    if (_usesBarnManagerChat) {
      Get.to(
        () => BarnManagerSingleChatView(
          name: name,
          image: image,
          conversationId: conversationId,
          otherId: otherId,
        ),
      );
      return;
    }

    Get.to(
      () => SingleChatView(
        name: name,
        image: image,
        conversationId: conversationId,
        otherId: otherId,
        readOnly: readOnly,
      ),
    );
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
      openChatThread(
        name: otherName,
        image: otherImage,
        conversationId: existingConvo.conversationId,
        otherId: otherId,
      );
      return;
    }

    // 1.2 Fallback: If no specific booking thread found, try to find ANY existing general chat 
    // with this specific user in our current inbox list.
    final existingWithUser = conversations.firstWhereOrNull(
      (c) => c.otherUser?.id == otherId || c.otherUser?.trainerId == otherId || c.otherUser?.vendorId == otherId,
    );
    if (existingWithUser != null) {
      openChatThread(
        name: otherName,
        image: otherImage,
        conversationId: existingWithUser.conversationId,
        otherId: otherId,
      );
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
      openChatThread(
        name: otherName,
        image: otherImage,
        conversationId: existingPersonal.conversationId,
        otherId: otherId,
      );
      return;
    }

    // 5. Final fallback - Create new personal thread
    openChatThread(
      name: otherName,
      image: otherImage,
      conversationId: personalConvoId,
      otherId: otherId,
    );
  }

  void _handleSentConfirmation(String tempId, ChatMessage message) {
    final me = _authController.currentUser.value?.id ?? '';
    if (_isSameChatThread(activeConversationId.value, message.conversationId, me) ||
        activeConversationId.value == tempId) {
      if (activeConversationId.value != message.conversationId) {
        _logger.i(
          '🔄 Syncing activeConversationId to canonical ID: ${message.conversationId}',
        );
        _syncActiveConversationRoom(message.conversationId);
      }
    }

    // Remove any other instances of this real ID that might have arrived before the confirmation
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
    final BookingController bc = lookupBookingController();
    bc.fetchBookings(type: 'received');
    bc.fetchBookings(type: 'sent');
    bc.refreshPendingBookingCounts();
  }
}

