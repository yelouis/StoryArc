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

  Map<String, dynamic> toMap() {
    return {
      'geminiApiKey': geminiApiKey,
      'personaPrompt': personaPrompt,
      'isHapticFeedbackEnabled': isHapticFeedbackEnabled,
      'useUserApiKey': useUserApiKey,
    };
  }

  factory AppConfig.fromMap(Map<String, dynamic> map) {
    return AppConfig(
      geminiApiKey: map['geminiApiKey'],
      personaPrompt: map['personaPrompt'] ?? "You are a cinematic story architect...",
      isHapticFeedbackEnabled: map['isHapticFeedbackEnabled'] ?? true,
      useUserApiKey: map['useUserApiKey'] ?? false,
    );
  }
}
