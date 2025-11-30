class Environment {
  Environment._();

  // For local development, use: http://localhost:5000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:'https://samparka-1.onrender.com',
  );

  static bool get isProduction => apiBaseUrl.contains('samparka-n7ps.onrender.com');
}
