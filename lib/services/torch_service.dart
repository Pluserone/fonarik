import 'package:flutter/foundation.dart';
import 'package:torch_light/torch_light.dart';

/// Сервис управления физической вспышкой телефона (фонариком)
class TorchService {
  static final TorchService _instance = TorchService._internal();
  factory TorchService() => _instance;
  TorchService._internal();

  bool _isTorchOn = false;
  bool _isAvailable = false;
  bool _checkedAvailability = false;

  bool get isTorchOn => _isTorchOn;
  bool get isAvailable => _isAvailable;

  /// Проверка доступности физической вспышки на устройстве
  Future<bool> checkAvailability() async {
    if (_checkedAvailability) return _isAvailable;
    try {
      _isAvailable = await TorchLight.isTorchAvailable();
    } catch (e) {
      debugPrint('Ошибка проверки доступности фонарика: $e');
      _isAvailable = false;
    }
    _checkedAvailability = true;
    return _isAvailable;
  }

  /// Включение фонарика
  Future<bool> turnOn() async {
    try {
      final available = await checkAvailability();
      if (available) {
        await TorchLight.enableTorch();
      } else {
        debugPrint('Физический фонарик недоступен (симуляция)');
      }
      _isTorchOn = true;
      return true;
    } catch (e) {
      debugPrint('Ошибка включения фонарика: $e');
      _isTorchOn = true; // Сохраняем состояние интерфейса даже при ошибке на эмуляторе
      return false;
    }
  }

  /// Выключение фонарика
  Future<bool> turnOff() async {
    try {
      final available = await checkAvailability();
      if (available) {
        await TorchLight.disableTorch();
      }
      _isTorchOn = false;
      return true;
    } catch (e) {
      debugPrint('Ошибка выключения фонарика: $e');
      _isTorchOn = false;
      return false;
    }
  }

  /// Переключение состояния
  Future<bool> toggle() async {
    if (_isTorchOn) {
      return await turnOff();
    } else {
      return await turnOn();
    }
  }
}
