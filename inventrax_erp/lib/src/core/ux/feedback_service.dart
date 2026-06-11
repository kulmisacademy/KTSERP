import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Optional haptic / system sounds for POS-grade feedback.
class FeedbackSettings {
  const FeedbackSettings({
    this.soundsEnabled = true,
    this.hapticsEnabled = true,
  });

  final bool soundsEnabled;
  final bool hapticsEnabled;

  FeedbackSettings copyWith({bool? soundsEnabled, bool? hapticsEnabled}) {
    return FeedbackSettings(
      soundsEnabled: soundsEnabled ?? this.soundsEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }
}

class FeedbackSettingsController extends Notifier<FeedbackSettings> {
  @override
  FeedbackSettings build() => const FeedbackSettings();

  void setSounds(bool value) => state = state.copyWith(soundsEnabled: value);

  void setHaptics(bool value) => state = state.copyWith(hapticsEnabled: value);
}

final feedbackSettingsProvider =
    NotifierProvider<FeedbackSettingsController, FeedbackSettings>(
  FeedbackSettingsController.new,
);

final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  return FeedbackService(ref.watch(feedbackSettingsProvider));
});

class FeedbackService {
  FeedbackService(this._settings);

  final FeedbackSettings _settings;

  void barcodeScanned() {
    if (_settings.hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
    _playClick();
  }

  void checkoutSuccess() {
    if (_settings.hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    _playClick();
  }

  void warning() {
    if (_settings.hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  void _playClick() {
    if (!_settings.soundsEnabled || kIsWeb) return;
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }
}
