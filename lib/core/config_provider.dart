import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/app_config.dart';

final configProvider = StateNotifierProvider<ConfigNotifier, AppConfig>((ref) {
  return ConfigNotifier();
});

class ConfigNotifier extends StateNotifier<AppConfig> {
  final _storage = const FlutterSecureStorage();
  static const _apiKeySecretKey = 'gemini_api_key';

  ConfigNotifier() : super(AppConfig()) {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final apiKey = await _storage.read(key: _apiKeySecretKey);
    state = state.copyWith(geminiApiKey: apiKey);
  }

  Future<void> setApiKey(String apiKey) async {
    await _storage.write(key: _apiKeySecretKey, value: apiKey);
    state = state.copyWith(geminiApiKey: apiKey);
  }

  Future<void> clearApiKey() async {
    await _storage.delete(key: _apiKeySecretKey);
    state = state.copyWith(geminiApiKey: null);
  }

  void updatePersonaPrompt(String prompt) {
    state = state.copyWith(personaPrompt: prompt);
    // TODO: Persist to Firestore if needed
  }

  void setHapticFeedback(bool enabled) {
    state = state.copyWith(isHapticFeedbackEnabled: enabled);
  }

  void setUseUserApiKey(bool use) {
    state = state.copyWith(useUserApiKey: use);
  }
}
