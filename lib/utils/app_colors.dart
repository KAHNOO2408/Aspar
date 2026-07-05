import 'package:flutter/material.dart';

class AppColors {
  static bool _isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) =>
      _isDark(context) ? const Color(0xFF121212) : const Color(0xFFF4F6FB);

  static Color card(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1E1E1E) : Colors.white;

  static Color text(BuildContext context) =>
      _isDark(context) ? Colors.white : Colors.black87;

  static Color textSecondary(BuildContext context) =>
      _isDark(context) ? Colors.grey.shade500 : Colors.grey.shade600;

  static Color textMuted(BuildContext context) =>
      _isDark(context) ? Colors.grey.shade600 : Colors.grey.shade400;

  static Color divider(BuildContext context) =>
      _isDark(context) ? Colors.grey.shade800 : Colors.grey.shade200;

  static Color shadow(BuildContext context) =>
      _isDark(context) ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.04);

  static Color inputFill(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1E1E1E) : Colors.white;
}
