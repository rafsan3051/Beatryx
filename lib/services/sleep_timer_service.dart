import 'dart:async';
import 'package:flutter/foundation.dart';

class SleepTimerService extends ChangeNotifier {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  bool _isActive = false;
  Function? _onComplete;

  Duration get remainingTime => _remainingTime;
  bool get isActive => _isActive;
  String get formattedTime {
    final minutes = _remainingTime.inMinutes;
    final seconds = _remainingTime.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void start(Duration duration, {Function? onComplete}) {
    if (_isActive) {
      stop();
    }
    
    _remainingTime = duration;
    _isActive = true;
    _onComplete = onComplete;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        notifyListeners();
      } else {
        stop();
        if (_onComplete != null) {
          _onComplete!();
        }
      }
    });
    
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _isActive = false;
    _remainingTime = Duration.zero;
    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void resume() {
    if (_remainingTime.inSeconds > 0 && !_isActive) {
      _isActive = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
          notifyListeners();
        } else {
          stop();
          if (_onComplete != null) {
            _onComplete!();
          }
        }
      });
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

