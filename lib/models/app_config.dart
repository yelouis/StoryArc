class AppConfig {
  final String? geminiApiKey;
  final String personaPrompt;
  final bool isHapticFeedbackEnabled;
  final bool useUserApiKey;

  AppConfig({
    this.geminiApiKey,
    this.personaPrompt = "You are a cinematic story architect. Your goal is to help the user reflect on their life by asking deep, empathetic questions and identifying the 'Plotlines' of their journey.",
    this.isHapticFeedbackEnabled = true,
    this.useUserApiKey = false,
  });

  AppConfig copyWith({
    String? geminiApiKey,
    String? personaPrompt,
    bool? isHapticFeedbackEnabled,
    bool? useUserApiKey,
  }) {
    return AppConfig(
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      personaPrompt: personaPrompt ?? this.personaPrompt,
      isHapticFeedbackEnabled: isHapticFeedbackEnabled ?? this.isHapticFeedbackEnabled,
      useUserApiKey: useUserApiKey ?? this.useUserApiKey,
    );
  }
}
