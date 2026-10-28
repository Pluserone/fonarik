import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Кнопка переключения темы (Солнце для светлой / Луна со свечением для тёмной)
class ThemeToggleButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const ThemeToggleButton({
    super.key,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onToggle();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? const Color(0xFF14161E) : AppTheme.lightBg,
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.8),
            width: 1.5,
          ),
          boxShadow: isDark
              ? [
                  // Мягкая белая подсветка/свечение Луны в темной теме
                  BoxShadow(
                    color: Colors.white.withOpacity(0.25),
                    blurRadius: 18,
                    spreadRadius: 2,
                    offset: const Offset(0, 0),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.7),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  // Скевоморфный рельеф в светлой теме
                  const BoxShadow(
                    color: Color(0x35000000),
                    blurRadius: 10,
                    offset: Offset(3, 4),
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    blurRadius: 8,
                    offset: Offset(-3, -3),
                  ),
                ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: Tween<double>(begin: 0.75, end: 1.0).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: isDark
                ? const Icon(
                    Icons.nightlight_round,
                    key: ValueKey('moon'),
                    size: 26,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.white,
                        blurRadius: 12,
                      ),
                    ],
                  )
                : const Icon(
                    Icons.wb_sunny_rounded,
                    key: ValueKey('sun'),
                    size: 28,
                    color: Color(0xFF2C303B),
                  ),
          ),
        ),
      ),
    );
  }
}
