import 'package:catch_ride/constant/app_urls.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SocketService extends GetxService {
  late io.Socket socket;
  bool _isSocketInitialized = false;
  final Logger _logger = Logger();

  final RxBool isConnected = false.obs;
  final List<void Function()> _refreshCallbacks = [];

  @override
  void onInit() {
    // Socket is NOT connected here. Connection happens only after login
    // via authenticate(), or on session restore in AuthController.
    super.onInit();
  }

  void initSocket() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Attempt to pull user data for handshake authentication
    final String userId = prefs.getString('userId') ?? '';
    final String firstName = prefs.getString('userFirstName') ?? '';
    final String lastName = prefs.getString('userLastName') ?? '';
    final String userName = '$firstName $lastName'.trim();
    final String userRole = prefs.getString('role') ?? '';
    final String token = prefs.getString('token') ?? '';
    final String email = prefs.getString('userEmail') ?? '';

    _logger.i('Initializing Socket Connection to ${AppUrls.socketUrl}');
    if (userId.isNotEmpty) {
      _logger.i('🔄 Using Handshake Authentication for User: $userName ($userId)');
    }

    socket = io.io(
      AppUrls.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({
            'caller': 'flutter',
            if (userId.isNotEmpty) 'userId': userId,
            if (userName.isNotEmpty) 'userName': userName,
            if (userRole.isNotEmpty) 'userRole': userRole,
          })
          .setAuth({
            if (token.isNotEmpty) 'token': token,
            if (email.isNotEmpty) 'email': email,
            if (userId.isNotEmpty) 'userId': userId,
          })
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(3000)
          .setReconnectionAttempts(50)
          .build(),
    );
    _isSocketInitialized = true;

    socket.onConnect((_) {
      _logger.i('Socket Connected');
      isConnected.value = true;
    });

    socket.onDisconnect((_) {
      _logger.w('Socket Disconnected');
      isConnected.value = false;
    });

    socket.onConnectError((err) {
      _logger.e('Socket Connection Error: $err');
      isConnected.value = false;
    });

    socket.onError((err) {
      _logger.e('Socket Error: $err');
    });

    // Global listener for all incoming events
    socket.onAny((event, data) {
      try {
        _logger.d('📥 SOCKET RECV [$event]: ${jsonEncode(data)}');
      } catch (e) {
        _logger.d('📥 SOCKET RECV [$event]: $data');
      }
    });

    // Only connect if the user is authenticated (userId present)
    if (userId.isNotEmpty) {
      _logger.i('✅ User authenticated, connecting socket...');
      connect();
    } else {
      _logger.i('⏸ No user session found — socket will connect after login.');
    }
  }

  Future<void> authenticate(String userId, String userName, String? userRole, {String? avatar, String? token, String? email}) async {
    try {
      _logger.i('🔄 Upgrading Socket to Handshake Authentication for $userName');
      
      // Ensure data is in SharedPreferences for reconnection/persistence
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);
      await prefs.setString('role', userRole ?? '');
      if (token != null) await prefs.setString('token', token);
      if (email != null) await prefs.setString('userEmail', email);
      
      // Split name safely to sync with AuthController's storage pattern
      final parts = userName.trim().split(' ');
      if (parts.isNotEmpty && parts.first.isNotEmpty) {
        await prefs.setString('userFirstName', parts.first);
        if (parts.length > 1) {
          await prefs.setString('userLastName', parts.sublist(1).join(' '));
        } else {
          await prefs.setString('userLastName', '');
        }
      } else {
        await prefs.setString('userFirstName', userName);
        await prefs.setString('userLastName', '');
      }
      
      if (avatar != null) await prefs.setString('userAvatar', avatar);

      // Re-initialize the socket with the new query parameters
      // This forces a new connection with the handshake data
      if (_isSocketInitialized) {
        if (socket.connected) {
          socket.disconnect();
        }
        socket.clearListeners();
        socket.dispose();
      }
      
      // Re-run initialization which will now pick up the new data from SharedPreferences
      initSocket();

      // Notify listeners that the socket has been refreshed
      for (var callback in _refreshCallbacks) {
        callback();
      }
    } catch (e, stack) {
      _logger.e('Error during socket authentication upgrade: $e');
      _logger.e(stack);
    }
  }


  void onRefresh(void Function() callback) {
    _refreshCallbacks.add(callback);
  }

  void connect() {
    if (_isSocketInitialized && !socket.connected) {
      socket.connect();
    }
  }

  void disconnect() {
    if (_isSocketInitialized && socket.connected) {
      socket.disconnect();
    }
  }

  void emit(String event, dynamic data) {
    if (_isSocketInitialized && socket.connected) {
      try {
        _logger.d('📤 SOCKET EMIT [$event]: ${jsonEncode(data)}');
      } catch (e) {
        _logger.d('📤 SOCKET EMIT [$event]: $data');
      }
      socket.emit(event, data);
    } else {
      _logger.w('Cannot emit $event: Socket not connected');
    }
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
