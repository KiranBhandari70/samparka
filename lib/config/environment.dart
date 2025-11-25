class Environment {
  Environment._();

  // For local development, use: http://localhost:5000
  // For production, use: https://api.samparka.com
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:'http://10.10.8.168:5000'
    // 'https://samparka-n7ps.onrender.com', // Change to your backend URL
  );

  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'wss://socket.samparka.com',
  );

  static const String apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: '',
  );

  static bool get isProduction => apiBaseUrl.contains('samparka-n7ps.onrender.com');
  static bool get isDevelopment => !isProduction;
}
