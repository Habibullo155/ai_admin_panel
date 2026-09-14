import 'package:flutter/widgets.dart';

enum DeviceType { mobile, tablet, desktop, largeDesktop }

class Responsive {
  static const mobileMax = 600.0;
  static const tabletMax = 1024.0;
  static const desktopMax = 1440.0;

  static DeviceType deviceTypeOf(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return typeForWidth(w);
  }

  static DeviceType typeForWidth(double w) {
    if (w < mobileMax) return DeviceType.mobile;
    if (w < tabletMax) return DeviceType.tablet;
    if (w < desktopMax) return DeviceType.desktop;
    return DeviceType.largeDesktop;
  }

  static bool isMobile(BuildContext context) =>
      deviceTypeOf(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) =>
      deviceTypeOf(context) == DeviceType.tablet;

  static bool isDesktopOrWider(BuildContext context) {
    final t = deviceTypeOf(context);
    return t == DeviceType.desktop || t == DeviceType.largeDesktop;
  }

  /// Показывать ли постоянную боковую панель (не выдвижную).
  static bool showPersistentSidebar(BuildContext context) =>
      !isMobile(context);

  /// Максимальная ширина ленты сообщений — на очень широких экранах
  /// текст не должен растягиваться на весь монитор.
  static double chatMaxWidth(BuildContext context) {
    final type = deviceTypeOf(context);
    switch (type) {
      case DeviceType.mobile:
        return double.infinity;
      case DeviceType.tablet:
        return 720;
      case DeviceType.desktop:
        return 820;
      case DeviceType.largeDesktop:
        return 900;
    }
  }

  static double sidebarWidth(BuildContext context) {
    final type = deviceTypeOf(context);
    switch (type) {
      case DeviceType.tablet:
        return 260;
      case DeviceType.desktop:
        return 300;
      case DeviceType.largeDesktop:
        return 320;
      case DeviceType.mobile:
        return 280;
    }
  }
}
