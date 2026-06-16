import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme_preset.dart';

final themeNotifierProvider =
    NotifierProvider<ThemeNotifier, ThemePreset>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<ThemePreset> {
  static const _key = 'app_theme_id';

  @override
  ThemePreset build() {
    _loadSaved();
    return ThemePreset.ocean;
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == null) return;
    final preset = ThemePreset.all.firstWhere(
      (p) => p.id.name == saved,
      orElse: () => ThemePreset.ocean,
    );
    state = preset;
  }

  Future<void> setTheme(ThemePreset preset) async {
    state = preset;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, preset.id.name);
  }
}
