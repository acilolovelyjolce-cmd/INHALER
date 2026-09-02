abstract final class AppConfig {
  /// Backend origin.
  /// - Empty in a **web release** build: same origin (Render).
  /// - Empty on **iOS/Android release**: [publicBaseUrl] (the live site).
  /// - Empty in **debug/tests**: in-memory sample data.
  /// - `http://localhost:8080` for local API.
  /// - `demo` to force in-memory data.
  static const apiUrl = String.fromEnvironment('API_URL');

  static const publicBaseUrl = String.fromEnvironment(
    'PUBLIC_BASE_URL',
    defaultValue: 'https://inhaler.onrender.com',
  );

  static bool get useDemo {
    if (apiUrl == 'demo') return true;
    if (apiUrl.isNotEmpty) return false;
    return !const bool.fromEnvironment('dart.vm.product');
  }

  static bool get isConfigured => !useDemo;
}
