import 'dart:async';

/// Coalesces rapid keystrokes (search) into a single callback.
class Debouncer {
  Debouncer({this.duration = const Duration(milliseconds: 200)});

  final Duration duration;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => cancel();
}
