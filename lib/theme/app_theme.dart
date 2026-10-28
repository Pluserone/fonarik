import 'package:flutter/material.dart';

/// Цветовые палитры и стили скевоморфного дизайна для светлой и тёмной тем
class AppTheme {
  // Светлая тема - эффект матового светлого пластика с глубокими тенями
  static const Color lightBg = Color(0xFFE6E9EF);
  static const Color lightTrackBg = Color(0xFFDDE1E8);
  static const Color lightTextPrimary = Color(0xFF1E222B);
  static const Color lightTextMuted = Color(0xFF8C93A3);
  static const Color lightShadowDark = Color(0x35000000);
  static const Color lightShadowLight = Color(0xDFFFFFFF);

  // Тёмная тема - глубокий ониксовый корпус с мягким белым свечением
  static const Color darkBg = Color(0xFF0C0D11);
  static const Color darkTrackBg = Color(0xFF14161D);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextMuted = Color(0xFF6B7280);
  static const Color darkWhiteGlow = Color(0x55FFFFFF);
  static const Color darkWhiteGlowIntense = Color(0x8AFFFFFF);

  // Стиль заголовка
  static TextStyle headerStyle({required bool isDark}) {
    return TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w900,
      letterSpacing: 2.0,
      fontFamily: 'sans-serif',
      color: isDark ? darkTextPrimary : lightTextPrimary,
      shadows: isDark
          ? [
              const Shadow(
                color: Color(0x40FFFFFF),
                blurRadius: 16,
                offset: Offset(0, 0),
              ),
            ]
          : [
              const Shadow(
                color: Colors.white,
                blurRadius: 2,
                offset: Offset(0, 1.5),
              ),
            ],
    );
  }

  // Стиль надписей ON / OFF
  static TextStyle labelStyle({
    required bool isDark,
    required bool isActive,
  }) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      letterSpacing: 3.0,
      color: isDark
          ? (isActive ? Colors.white : darkTextMuted)
          : (isActive ? lightTextPrimary : lightTextMuted),
      shadows: isDark && isActive
          ? [
              const Shadow(
                color: Colors.white,
                blurRadius: 14,
                offset: Offset(0, 0),
              ),
              const Shadow(
                color: Color(0x80FFFFFF),
                blurRadius: 24,
                offset: Offset(0, 0),
              ),
            ]
          : null,
    );
  }

  // Стиль ссылки в футере
  static TextStyle linkStyle({required bool isDark}) {
    return TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
      color: isDark ? const Color(0xFFD4D8E2) : const Color(0xFF333842),
    );
  }
}
