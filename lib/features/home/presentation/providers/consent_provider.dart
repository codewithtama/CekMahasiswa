import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsentNotifier extends StateNotifier<AsyncValue<bool>> {
  ConsentNotifier() : super(const AsyncValue.loading()) {
    _loadConsent();
  }

  static const _keyConsent = 'pddikti_user_consent';

  Future<void> _loadConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final consent = prefs.getBool(_keyConsent) ?? false;
      state = AsyncValue.data(consent);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> grantConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyConsent, true);
      state = const AsyncValue.data(true);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> revokeConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyConsent, false);
      state = const AsyncValue.data(false);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final consentProvider = StateNotifierProvider<ConsentNotifier, AsyncValue<bool>>((ref) {
  return ConsentNotifier();
});
