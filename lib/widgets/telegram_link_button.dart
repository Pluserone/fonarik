import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

/// Кликабельная ссылка внизу экрана на Telegram-канал
class TelegramLinkButton extends StatelessWidget {
  final bool isDark;

  const TelegramLinkButton({
    super.key,
    required this.isDark,
  });

  Future<void> _openTelegram(BuildContext context) async {
    HapticFeedback.lightImpact();
    const urlString = 'https://t.me/pluseron';
    final uri = Uri.parse(urlString);

    try {
      // Сначала пробуем открыть через внешнее приложение (Telegram или браузер)
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось открыть ссылку: $urlString'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openTelegram(context),
      borderRadius: BorderRadius.circular(24),
      splashColor: isDark ? Colors.white12 : Colors.black12,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isDark ? const Color(0xFF14161F) : AppTheme.lightBg,
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.7),
            width: 1.2,
          ),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 0),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Color(0x25000000),
                    blurRadius: 8,
                    offset: Offset(2, 3),
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    blurRadius: 6,
                    offset: Offset(-2, -2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.send_rounded,
              size: 18,
              color: isDark ? Colors.white70 : const Color(0xFF4A5160),
            ),
            const SizedBox(width: 8),
            Text(
              't.me/pluseron',
              style: AppTheme.linkStyle(isDark: isDark),
            ),
          ],
        ),
      ),
    );
  }
}
