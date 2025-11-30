class Environment {
  Environment._();

  // For local development, use: http://localhost:5000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:'http://192.168.1.166:5000',
  );

  static bool get isProduction => apiBaseUrl.contains('samparka-n7ps.onrender.com');
}
