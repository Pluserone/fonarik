import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Скевоморфный вертикальный блок-слайдер с физической кнопкой в углублении
class SkeuomorphicSlider extends StatefulWidget {
  final bool isOn;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const SkeuomorphicSlider({
    super.key,
    required this.isOn,
    required this.isDark,
    required this.onChanged,
  });

  @override
  State<SkeuomorphicSlider> createState() => _SkeuomorphicSliderState();
}

class _SkeuomorphicSliderState extends State<SkeuomorphicSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _positionAnimation;

  // Размеры блока углубления и кнопки
  final double _trackWidth = 144.0;
  final double _trackHeight = 350.0;
  final double _knobSize = 108.0;
  final double _trackPadding = 18.0;
  final double _topMargin = 58.0; // отступ сверху для читаемости надписи ON
  final double _bottomMargin = 58.0; // отступ снизу для читаемости надписи OFF

  double get _maxTravel => _trackHeight - _knobSize - _topMargin - _bottomMargin;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _positionAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    );

    if (widget.isOn) {
      _animController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant SkeuomorphicSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOn != oldWidget.isOn) {
      if (widget.isOn) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.heavyImpact();
    widget.onChanged(!widget.isOn);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    // Вычисление относительного перемещения при свайпе
    final delta = -details.primaryDelta! / _maxTravel;
    _animController.value = (_animController.value + delta).clamp(0.0, 1.0);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    HapticFeedback.mediumImpact();
    final shouldBeOn = _animController.value > 0.5;
    if (shouldBeOn != widget.isOn) {
      widget.onChanged(shouldBeOn);
    } else {
      if (widget.isOn) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final isOn = widget.isOn;

    return GestureDetector(
      onTap: _toggle,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: _trackWidth,
        height: _trackHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_trackWidth / 2),
          color: isDark ? const Color(0xFF13151D) : const Color(0xFFD6DBE5),
          // Эффект физического углубления (ниши) в корпусе
          border: Border.all(
            color: isDark
                ? (isOn ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.12))
                : Colors.white.withOpacity(0.7),
            width: 2.0,
          ),
          boxShadow: isDark
              ? [
                  // Мягкая белая подсветка/свечение из пустоты в тёмной теме
                  BoxShadow(
                    color: Colors.white.withOpacity(isOn ? 0.30 : 0.10),
                    blurRadius: isOn ? 45 : 22,
                    spreadRadius: isOn ? 4 : 1,
                    offset: const Offset(0, 0),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.85),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [
                  // Глубокие тени продавленной ниши в светлой теме
                  const BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 14,
                    offset: Offset(4, 6),
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    blurRadius: 12,
                    offset: Offset(-4, -4),
                  ),
                ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Внутренний градиент глубины ниши (имитация углубления)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_trackWidth / 2),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ]
                          : [
                              Colors.black.withOpacity(0.18),
                              Colors.transparent,
                              Colors.white.withOpacity(0.35),
                            ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // Текстовая метка "ON" в верхней части ниши
            Positioned(
              top: 22,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: AppTheme.labelStyle(
                  isDark: isDark,
                  isActive: isOn,
                ),
                child: const Text('ON'),
              ),
            ),

            // Текстовая метка "OFF" в нижней части ниши
            Positioned(
              bottom: 22,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: AppTheme.labelStyle(
                  isDark: isDark,
                  isActive: !isOn,
                ),
                child: const Text('OFF'),
              ),
            ),

            // Круглая физическая кнопка-переключатель (цилиндр)
            AnimatedBuilder(
              animation: _positionAnimation,
              builder: (context, child) {
                // value = 0.0 -> OFF (внизу), value = 1.0 -> ON (вверху)
                final topOffset = _topMargin +
                    (_maxTravel * (1.0 - _positionAnimation.value));

                return Positioned(
                  top: topOffset,
                  child: _buildCylindricalKnob(isDark, isOn),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Построение объемной физической кнопки-цилиндра
  Widget _buildCylindricalKnob(bool isDark, bool isOn) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _knobSize,
      height: _knobSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Реалистичный градиент скошенных краев цилиндра
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? (isOn
                  ? [
                      const Color(0xFF3F4554),
                      const Color(0xFF1D2028),
                    ]
                  : [
                      const Color(0xFF282B34),
                      const Color(0xFF14161C),
                    ])
              : (isOn
                  ? [
                      Colors.white,
                      const Color(0xFFD6DBE5),
                    ]
                  : [
                      const Color(0xFFF9FAFC),
                      const Color(0xFFC7CDD8),
                    ]),
        ),
        border: Border.all(
          color: isDark
              ? (isOn ? Colors.white.withOpacity(0.8) : Colors.white.withOpacity(0.2))
              : Colors.white.withOpacity(0.9),
          width: 2.0,
        ),
        boxShadow: isDark
            ? [
                // Свечение кнопки при активации в тёмной теме
                if (isOn) ...[
                  BoxShadow(
                    color: Colors.white.withOpacity(0.55),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
                BoxShadow(
                  color: Colors.black.withOpacity(0.9),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                // Объемные реалистичные тени цилиндра в светлой теме
                BoxShadow(
                  color: Colors.black.withOpacity(0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
                const BoxShadow(
                  color: Colors.white,
                  blurRadius: 8,
                  offset: Offset(0, -3),
                ),
              ],
      ),
      child: Center(
        child: Container(
          width: _knobSize * 0.76,
          height: _knobSize * 0.76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: isDark
                  ? (isOn
                      ? [const Color(0xFF2B303C), const Color(0xFF171920)]
                      : [const Color(0xFF20232B), const Color(0xFF101217)])
                  : (isOn
                      ? [const Color(0xFFF4F6F9), const Color(0xFFCDD3DE)]
                      : [const Color(0xFFEBEFF5), const Color(0xFFBCC3D0)]),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Center(
            // Значок питания (Power ⏻) в точности как на приложенном эскизе
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.power_settings_new_rounded,
                key: ValueKey('power_${isOn}_$isDark'),
                size: 38,
                color: isDark
                    ? (isOn ? Colors.white : const Color(0xFF5A6172))
                    : (isOn ? const Color(0xFF15181F) : const Color(0xFF7E8696)),
                shadows: (isDark && isOn)
                    ? [
                        const Shadow(
                          color: Colors.white,
                          blurRadius: 16,
                        ),
                        const Shadow(
                          color: Colors.white,
                          blurRadius: 28,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
