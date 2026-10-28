import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'services/torch_service.dart';
import 'widgets/theme_toggle_button.dart';
import 'widgets/skeuomorphic_slider.dart';
import 'widgets/telegram_link_button.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Фиксируем только вертикальную ориентацию для стабильности дизайна
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const FlashlightApp());
}

class FlashlightApp extends StatefulWidget {
  const FlashlightApp({super.key});

  @override
  State<FlashlightApp> createState() => _FlashlightAppState();
}

class _FlashlightAppState extends State<FlashlightApp> {
  // По умолчанию открываем в темной теме для красивого эффекта свечения
  bool _isDark = true;

  void _toggleTheme() {
    setState(() {
      _isDark = !_isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Настраиваем цвет системных панелей (Status Bar и Navigation Bar)
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: _isDark ? AppTheme.darkBg : AppTheme.lightBg,
        systemNavigationBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'Фонарик',
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppTheme.lightBg,
        fontFamily: 'sans-serif',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppTheme.darkBg,
        fontFamily: 'sans-serif',
      ),
      home: FlashlightScreen(
        isDark: _isDark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class FlashlightScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const FlashlightScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<FlashlightScreen> createState() => _FlashlightScreenState();
}

class _FlashlightScreenState extends State<FlashlightScreen>
    with WidgetsBindingObserver {
  final TorchService _torchService = TorchService();
  bool _isOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initTorch();
  }

  Future<void> _initTorch() async {
    await _torchService.checkAvailability();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // При сворачивании приложения выключаем вспышку для экономии заряда батареи
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      if (_isOn) {
        _handleToggle(false);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isOn) {
      _torchService.turnOff();
    }
    super.dispose();
  }

  Future<void> _handleToggle(bool value) async {
    setState(() {
      _isOn = value;
    });

    if (value) {
      final success = await _torchService.turnOn();
      if (!success && mounted && !_torchService.isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Вспышка не обнаружена (режим симулятора)'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      await _torchService.turnOff();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ==========================================
              // 1. ВЕРХНЯЯ ЧАСТЬ: Заголовок и кнопка темы
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Заголовок приложения
                  Text(
                    'ЭТО ФОНАРИК',
                    style: AppTheme.headerStyle(isDark: isDark),
                  ),

                  // Кнопка переключения темы (Солнце / Луна со свечением)
                  ThemeToggleButton(
                    isDark: isDark,
                    onToggle: widget.onToggleTheme,
                  ),
                ],
              ),

              // ==========================================
              // 2. ЦЕНТРАЛЬНАЯ ЧАСТЬ: Скевоморфный слайдер
              // ==========================================
              Expanded(
                child: Center(
                  child: SkeuomorphicSlider(
                    isOn: _isOn,
                    isDark: isDark,
                    onChanged: _handleToggle,
                  ),
                ),
              ),

              // ==========================================
              // 3. НИЖНЯЯ ЧАСТЬ: Ссылка t.me/pluseron
              // ==========================================
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TelegramLinkButton(isDark: isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
