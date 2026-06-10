import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

typedef DataCallback = void Function(dynamic data);

class SocketService {
  static io.Socket? _socket;
  static bool _isConnected = false;
  static final Map<String, List<DataCallback>> _listeners = {};

  static bool get isConnected => _isConnected;

  static void connect(String userId) {
    if (_isConnected) return;

    // ⚠️ Ganti IP dengan IP PC kamu
    _socket = io.io(
      'http://10.82.60.51:5000',
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .setQuery({'userId': userId})
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      _isConnected = true;
      debugPrint('WebSocket connected');
      _socket!.emit('user_online', {'userId': userId});
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      debugPrint('WebSocket disconnected');
    });

    _socket!.on('new_post', (data) => _notifyListeners('new_post', data));
    _socket!.on('new_like', (data) => _notifyListeners('new_like', data));
    _socket!.on('new_comment', (data) => _notifyListeners('new_comment', data));
    _socket!.on('leaderboard_update', (data) => _notifyListeners('leaderboard_update', data));
    _socket!.on('mission_completed', (data) => _notifyListeners('mission_completed', data));
    _socket!.on('badge_earned', (data) => _notifyListeners('badge_earned', data));
  }

  static void on(String event, DataCallback callback) {
    _listeners.putIfAbsent(event, () => []).add(callback);
  }

  static void off(String event, DataCallback callback) {
    _listeners[event]?.remove(callback);
  }

  static void _notifyListeners(String event, dynamic data) {
    for (final cb in (_listeners[event] ?? [])) {
      cb(data);
    }
  }

  static void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _isConnected = false;
  }
}