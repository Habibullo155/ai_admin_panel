/// Значение можно задать при сборке флагом --dart-define, например:
///
///   flutter build web --dart-define=BACKEND_URL=https://your-tunnel.trycloudflare.com
///
/// Это нужно, когда фронтенд хостится отдельно (например GitHub Pages),
/// а бэкенд крутится у тебя на компьютере и "выставлен" наружу через
/// туннель (ngrok / Cloudflare Tunnel). Если флаг не передан — используется
/// localhost, что подходит для локальной разработки.
class AppConfig {
  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://localhost:8000',
  );
}
