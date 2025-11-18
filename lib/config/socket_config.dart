class SocketConfig {
  SocketConfig._();

  static const int reconnectInterval = 3000;
  static const int maxReconnectAttempts = 5;
  static const int heartbeatInterval = 30000;
  static const int connectionTimeout = 10000;

  static const Map<String, dynamic> defaultOptions = {
    'transports': ['websocket'],
    'autoConnect': true,
    'reconnection': true,
    'reconnectionDelay': reconnectInterval,
    'reconnectionAttempts': maxReconnectAttempts,
    'timeout': connectionTimeout,
  };
}
