import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindwealth_ai/providers/auth_provider.dart';

final isDarkModeProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  return profile?.theme != 'light';
});

class ThemeNotifier extends Notifier<bool> {
  @override
  bool build() {
    ref.listen(userProfileProvider, (_, next) {
      final profile = next.value;
      if (profile != null) {
        state = profile.theme != 'light';
      }
    });
    return true;
  }

  Future<void> toggleTheme() async {
    final newTheme = state ? 'light' : 'dark';
    state = !state;
    await ref.read(firebaseServiceProvider).updateTheme(newTheme);
  }
}

final themeNotifierProvider = NotifierProvider<ThemeNotifier, bool>(
  ThemeNotifier.new,
);
