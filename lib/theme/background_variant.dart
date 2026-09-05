// светлая/тёмная - отдельная ось от цветового варианта фона, можно
// сочетать любой из 9 вариантов с любым режимом
enum AppThemeMode { light, dark, system }

// 9 цветовых вариантов фона (3 было изначально + 6 новых). У каждого
// своя палитра и в тёмном, и в светлом режиме - см. app_background.dart
enum BackgroundVariant {
  violet,
  ocean,
  midnight,
  sunset,
  forest,
  rose,
  amber,
  slate,
  mint,
}
