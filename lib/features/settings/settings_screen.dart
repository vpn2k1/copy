import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/save/save_data.dart';
import '../../l10n/strings.dart';

/// Cài đặt âm thanh: âm nền, hiệu ứng, tắt tiếng. Đổi là lưu ngay xuống máy
/// (lưu khi thả thanh trượt, không lưu liên tục khi đang kéo).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// Giá trị đang kéo, chưa lưu.
  AudioSettings? draft;

  static const double _maxContentWidth = 520;

  @override
  Widget build(BuildContext context) {
    final profile = AppScope.of(context);
    final settings = draft ?? profile.settings;
    return Scaffold(
      appBar: AppBar(title: const Text(Strings.settingsTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  key: const Key('settings.mute'),
                  title: const Text(Strings.muteLabel),
                  value: settings.isMuted,
                  onChanged: (value) =>
                      profile.updateSettings(settings.copyWith(isMuted: value)),
                ),
                _slider(
                  key: 'settings.music',
                  label: Strings.musicVolumeLabel,
                  value: settings.musicVolume,
                  isEnabled: !settings.isMuted,
                  onDrag: (v) => settings.copyWith(musicVolume: v),
                  profile: profile,
                ),
                _slider(
                  key: 'settings.sfx',
                  label: Strings.sfxVolumeLabel,
                  value: settings.sfxVolume,
                  isEnabled: !settings.isMuted,
                  onDrag: (v) => settings.copyWith(sfxVolume: v),
                  profile: profile,
                ),
                const SizedBox(height: 12),
                const Text(Strings.settingsSavedNote),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _slider({
    required String key,
    required String label,
    required double value,
    required bool isEnabled,
    required AudioSettings Function(double value) onDrag,
    required ProfileNotifier profile,
  }) {
    return ListTile(
      title: Text(label),
      subtitle: Slider(
        key: Key(key),
        value: value,
        divisions: 10,
        label: Strings.percent((value * 100).round()),
        onChanged: _enabled(
          isEnabled,
          (v) => setState(() => draft = onDrag(v)),
        ),
        onChangeEnd: _enabled(isEnabled, (v) {
          profile.updateSettings(onDrag(v));
          setState(() => draft = null);
        }),
      ),
    );
  }

  ValueChanged<double>? _enabled(bool isEnabled, ValueChanged<double> action) {
    if (!isEnabled) return null;
    return action;
  }
}
