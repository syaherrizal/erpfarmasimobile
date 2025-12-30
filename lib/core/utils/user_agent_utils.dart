import 'package:flutter/material.dart';

class UserAgentUtils {
  static IconData getIcon(String? userAgent) {
    if (userAgent == null) return Icons.device_unknown;

    final ua = userAgent.toLowerCase();

    if (ua.contains('mobile') ||
        ua.contains('android') ||
        ua.contains('iphone')) {
      return Icons.phone_android;
    }

    if (ua.contains('mac') || ua.contains('macintosh')) {
      return Icons.laptop_mac; // Or computer
    }

    if (ua.contains('windows')) {
      return Icons.desktop_windows;
    }

    return Icons.computer;
  }

  static String getBrowserName(String? userAgent) {
    if (userAgent == null) return 'Unknown Device';

    final ua = userAgent.toLowerCase();
    if (ua.contains('chrome')) return 'Chrome';
    if (ua.contains('firefox')) return 'Firefox';
    if (ua.contains('safari') && !ua.contains('chrome')) return 'Safari';
    if (ua.contains('edge')) return 'Edge';

    return 'Browser';
  }

  static String getOsName(String? userAgent) {
    if (userAgent == null) return '';
    final ua = userAgent.toLowerCase();

    if (ua.contains('mac os')) return 'macOS';
    if (ua.contains('windows')) return 'Windows';
    if (ua.contains('android')) return 'Android';
    if (ua.contains('iphone os')) return 'iOS';
    if (ua.contains('linux')) return 'Linux';

    return '';
  }
}
