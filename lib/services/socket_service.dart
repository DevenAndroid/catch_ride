import 'package:catch_ride/constant/app_urls.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:logger/logger.dart';

class SocketService extends GetxService {
  late io.Socket socket;
  final Logger _logger = Logger();

  final RxBool isConnected = false.obs;

  @override
  void onInit() {
    initSocket();
    super.onInit();
  }

  void initSocket() {
    _logger.i('Initializing Socket Connection to ${AppUrls.socketUrl}');

    socket = io.io(
      AppUrls.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(3000)
          .setReconnectionAttempts(50)
          .build(),
    );

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

    // Example listener for system-wide notifications
    socket.on('notification', (data) {
      _logger.i('New Notification: $data');
      // You can trigger Get.snackbar or a local notification here
    });

    connect();
  }

  void authenticate(String userId, String userName, String? userRole) {
    if (socket.connected) {
      _logger.i('Authenticating Socket for $userName ($userId)');
      socket.emit('user:authenticate', {
        'userId': userId,
        'userName': userName,
        'userRole': userRole,
      });
    } else {
      _logger.w(
        'Cannot authenticate: Socket not connected. Will retry on connect.',
      );
      socket.once('connect', (_) => authenticate(userId, userName, userRole));
    }
  }

  void connect() {
    if (!socket.connected) {
      socket.connect();
    }
  }

  void disconnect() {
    if (socket.connected) {
      socket.disconnect();
    }
  }

  void emit(String event, dynamic data) {
    if (socket.connected) {
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
