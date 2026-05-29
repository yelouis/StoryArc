import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:story_arc/core/router.dart';
import 'package:story_arc/core/config_provider.dart';
import 'package:story_arc/models/app_config.dart';
import 'package:story_arc/models/plotline.dart';
import 'package:story_arc/models/session.dart';
import 'package:story_arc/repositories/plotline_repository.dart';
import 'package:story_arc/repositories/session_repository.dart';
import 'package:story_arc/features/onboarding/auth_service.dart';
import 'package:story_arc/services/analysis_service.dart';
import 'package:story_arc/services/audio_service.dart';
import 'package:story_arc/services/gemini_live_service.dart';

// --- Fakes & Mocks ---

class FakeUser extends Fake implements User {
  @override
  String get uid => 'user_123';
}

class MockAuthService extends Fake implements AuthService {
  @override
  User? get currentUser => FakeUser();

  @override
  Stream<User?> get authStateChanges => Stream.value(FakeUser());
}

class FakeConfigNotifier extends ConfigNotifier {
  FakeConfigNotifier() : super();

  @override
  Future<void> _loadConfig() async {
    // Avoid secure storage loading in tests
  }

  @override
  Future<void> setApiKey(String apiKey) async {
    state = state.copyWith(geminiApiKey: apiKey);
  }

  @override
  Future<void> clearApiKey() async {
    state = state.copyWith(geminiApiKey: null);
  }
}

class MockPlotlineRepository extends PlotlineRepository {
  final List<Plotline> plotlines = [];
  final _controller = StreamController<List<Plotline>>.broadcast();

  MockPlotlineRepository() : super(MockAuthService());

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.from(plotlines));
    }
  }

  @override
  Stream<List<Plotline>> getPlotlines() async* {
    yield List.from(plotlines);
    await for (final list in _controller.stream) {
      yield list;
    }
  }

  @override
  Future<void> addPlotline(Plotline plotline) async {
    plotlines.removeWhere((p) => p.id == plotline.id);
    plotlines.add(plotline);
    _emit();
  }

  @override
  Future<void> updatePlotline(Plotline plotline) async {
    plotlines.removeWhere((p) => p.id == plotline.id);
    plotlines.add(plotline);
    _emit();
  }

  @override
  Future<void> deletePlotline(String id) async {
    plotlines.removeWhere((p) => p.id == id);
    _emit();
  }

  @override
  Future<void> togglePin(String plotlineId, bool isPinned) async {
    final idx = plotlines.indexWhere((p) => p.id == plotlineId);
    if (idx != -1) {
      final p = plotlines[idx];
      plotlines[idx] = Plotline(
        id: p.id,
        title: p.title,
        emoji: p.emoji,
        createdAt: p.createdAt,
        lastActive: p.lastActive,
        isPinned: isPinned,
        description: p.description,
      );
      _emit();
    }
  }

  void dispose() {
    _controller.close();
  }
}

class MockSessionRepository extends SessionRepository {
  final List<Session> sessions = [];
  final _controller = StreamController<List<Session>>.broadcast();

  MockSessionRepository() : super(MockAuthService());

  void _emit(String plotlineId) {
    if (!_controller.isClosed) {
      _controller.add(sessions.where((s) => s.plotlineId == plotlineId).toList());
    }
  }

  @override
  Stream<List<Session>> getSessions(String plotlineId) async* {
    yield sessions.where((s) => s.plotlineId == plotlineId).toList();
    await for (final list in _controller.stream) {
      yield list.where((s) => s.plotlineId == plotlineId).toList();
    }
  }

  @override
  Future<void> addSession(Session session) async {
    sessions.removeWhere((s) => s.id == session.id);
    sessions.add(session);
    _emit(session.plotlineId);
  }

  @override
  Future<void> deleteSession(String plotlineId, String sessionId) async {
    sessions.removeWhere((s) => s.id == sessionId);
    _emit(plotlineId);
  }

  void dispose() {
    _controller.close();
  }
}

class MockAnalysisService extends AnalysisService {
  int callCount = 0;

  MockAnalysisService() : super('mock_api_key');

  void reset() {
    callCount = 0;
  }

  @override
  Future<AnalysisResult?> analyzeTranscript(String transcript) async {
    callCount++;
    if (callCount > 5) {
      throw RateLimitException("You are reflecting too quickly. Take a deep breath.");
    }

    await Future.delayed(const Duration(milliseconds: 10));

    // Dynamic suggestions based on transcript to match Sarah / Marcus paths
    if (transcript.contains("Launch") || transcript.contains("stressed")) {
      return AnalysisResult(
        title: 'Summit Friction',
        summary: 'A challenging product launch period reflecting team friction and anxiety.',
        moodKeyword: 'Struggling',
        moodScore: -0.4,
        emojis: ['😰', '🚀', '🧗'],
      );
    } else if (transcript.contains("obsidian") || transcript.contains("willow")) {
      if (transcript.contains("owl")) {
        return AnalysisResult(
          title: "The Willow's Witness",
          summary: 'Discovering the secret key under the weeping willow, guarded by the silent watcher, Aether.',
          moodKeyword: 'Inspired',
          moodScore: 0.8,
          emojis: ['🔑', '🌳', '🦉'],
        );
      }
      return AnalysisResult(
        title: 'obsidian key under the willow',
        summary: 'Protagonist finds an obsidian key in a weeping willow guarded by a falcon.',
        moodKeyword: 'Creative',
        moodScore: 0.6,
        emojis: ['🔑', '🌳', '🦅'],
      );
    }

    return AnalysisResult(
      title: 'Mock AI Title',
      summary: 'Mock AI Summary',
      moodKeyword: 'Neutral',
      moodScore: 0.0,
      emojis: ['💡', '✨', '📖'],
    );
  }
}

class MockGeminiLiveService extends GeminiLiveService {
  final _audioResponseController = StreamController<Uint8List>.broadcast();
  final _textResponseController = StreamController<String>.broadcast();
  String _mockTranscript = "";

  MockGeminiLiveService() : super('mock_api_key');

  @override
  Stream<Uint8List> get audioResponseStream => _audioResponseController.stream;

  @override
  Stream<String> get textResponseStream => _textResponseController.stream;

  @override
  String get fullTranscript => _mockTranscript;

  void setMockTranscript(String text) {
    _mockTranscript = text;
  }

  @override
  Future<void> connect() async {
    // No-op
  }

  @override
  void sendAudio(Uint8List audioChunk) {
    // No-op
  }

  @override
  void disconnect() {
    // No-op
  }

  @override
  void dispose() {
    _audioResponseController.close();
    _textResponseController.close();
  }
}

class MockAudioService extends AudioService {
  final _audioStreamController = StreamController<Uint8List>.broadcast();
  final _amplitudeController = StreamController<double>.broadcast();

  @override
  Stream<Uint8List> get audioStream => _audioStreamController.stream;

  @override
  Stream<double> get amplitudeStream => _amplitudeController.stream;

  @override
  Future<void> startRecording() async {
    // No-op
  }

  @override
  Future<void> stopRecording() async {
    // No-op
  }

  @override
  Future<void> initPlayback() async {
    // No-op
  }

  @override
  Future<void> playAudioChunk(Uint8List chunk) async {
    // No-op
  }

  @override
  void dispose() {
    _audioStreamController.close();
    _amplitudeController.close();
  }
}

// --- E2E User Journey Widget Tests ---

Future<void> pumpTransition(WidgetTester tester, {int steps = 15}) async {
  for (int i = 0; i < steps; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthService authService;
  late MockPlotlineRepository plotlineRepo;
  late MockSessionRepository sessionRepo;
  late FakeConfigNotifier configNotifier;
  late MockAnalysisService analysisService;
  late MockGeminiLiveService geminiLiveService;
  late MockAudioService audioService;

  setUp(() {
    // Mock platform channel for secure storage BEFORE creating FakeConfigNotifier
    const channel1 = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel1, (methodCall) async {
      return null;
    });

    const channel2 = MethodChannel('plugins.itrixgold.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel2, (methodCall) async {
      return null;
    });

    authService = MockAuthService();
    plotlineRepo = MockPlotlineRepository();
    sessionRepo = MockSessionRepository();
    configNotifier = FakeConfigNotifier();
    analysisService = MockAnalysisService();
    geminiLiveService = MockGeminiLiveService();
    audioService = MockAudioService();
  });

  tearDown(() {
    plotlineRepo.dispose();
    sessionRepo.dispose();
    geminiLiveService.dispose();
    audioService.dispose();
  });

  Widget createTestApp() {
    return ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(authService),
        plotlineRepositoryProvider.overrideWithValue(plotlineRepo),
        sessionRepositoryProvider.overrideWithValue(sessionRepo),
        configProvider.overrideWith((ref) => configNotifier),
        analysisServiceProvider.overrideWithValue(analysisService),
        geminiLiveServiceProvider.overrideWithValue(geminiLiveService),
        audioServiceProvider.overrideWithValue(audioService),
      ],
      child: Consumer(
        builder: (context, ref, child) {
          final router = ref.watch(routerProvider);
          print("ROUTER LOCATION IS CURRENTLY: ${router.routerDelegate.currentConfiguration.uri.toString()}");
          return MaterialApp.router(
            routerConfig: router,
          );
        },
      ),
    );
  }

  group('StoryArc E2E User Journeys', () {
    testWidgets("Sarah's Path - Onboarding, API key connection, Plotline, Voice session and Emoji Studio", (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestApp());
      await pumpTransition(tester);

      final container = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
      print("SARAH PATH STEP 1 LOCATION: ${container.read(routerProvider).routerDelegate.currentConfiguration.uri.toString()}");

      // 1. Verify Onboarding Prologue Screen is shown initially because API key is empty
      expect(find.text("Begin My Journey"), findsOneWidget);
      expect(find.text("Life is a series of\ninterwoven narratives."), findsOneWidget);

      // 2. Begin Journey to navigate to Connection Studio
      await tester.tap(find.text("Begin My Journey"));
      await pumpTransition(tester);

      print("SARAH PATH STEP 2 LOCATION: ${container.read(routerProvider).routerDelegate.currentConfiguration.uri.toString()}");

      expect(find.text("Connection Studio"), findsOneWidget);

      // 3. Paste/enter API key (must start with 'AIza') and submit
      await tester.enterText(find.byType(TextField), "AIzaSyDummyKey");
      await tester.tap(find.text("Test Connection"));
      await pumpTransition(tester);

      // 4. Verification that we successfully routed to Library Screen dashboard (empty state initially)
      expect(find.text("Your Plotlines"), findsOneWidget);
      expect(find.text("Start your first Plotline"), findsOneWidget);

      // 5. Create a Plotline named 'Product Launch 2026' with rocket emoji
      await tester.tap(find.text("New Narrative"));
      await pumpTransition(tester);

      expect(find.text("What's the name of this story?"), findsOneWidget);
      await tester.enterText(find.byType(TextField), "Product Launch 2026");

      // Tap default emoji box to open picker, select rocket
      await tester.tap(find.text("📖"));
      await pumpTransition(tester);

      // Trigger emoji selected directly on the EmojiPicker widget
      final emojiPicker = tester.widget<EmojiPicker>(find.byType(EmojiPicker));
      emojiPicker.onEmojiSelected!(null, const Emoji('🚀', 'rocket'));
      await pumpTransition(tester);

      // Tap Check/Save icon in app bar
      await tester.tap(find.byIcon(Icons.check));
      await pumpTransition(tester);

      // Verify the plotline displays in Library list
      expect(find.text("Product Launch 2026"), findsOneWidget);
      expect(find.text("🚀"), findsOneWidget);

      // 6. Navigate to Plotline Detail Screen
      await tester.tap(find.text("Product Launch 2026"));
      await pumpTransition(tester);
      expect(find.text("Product Launch 2026"), findsOneWidget);

      // 7. Start a Live Voice Session
      await tester.tap(find.byIcon(Icons.mic));
      await pumpTransition(tester);

      expect(find.text("Listening..."), findsOneWidget);

      // Simulate a stressed voice reflection response
      geminiLiveService.setMockTranscript("I feel stressed about the Product Launch 2026 and we are struggling with timeline issues.");
      
      // Tap the close button to end voice session and trigger AI Narrative Engine
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump(); // Start analysis & render loading overlay

      expect(find.text("Synthesizing Narrative..."), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 20)); // wait for analysis future
      await pumpTransition(tester);

      // 8. Emoji Studio bottom sheet suggested selection
      expect(find.text("Symbolic Anchor"), findsOneWidget);
      expect(find.text("🧗"), findsOneWidget);

      // Sarah rejects high anxiety suggestions and taps '🧗' (struggling climb)
      await tester.tap(find.text("🧗"));
      await pumpTransition(tester);

      // Defensively check if we popped back to Library screen, and navigate back to details if needed
      final currentLoc = container.read(routerProvider).routerDelegate.currentConfiguration.uri.toString();
      if (currentLoc == '/') {
        await tester.tap(find.text("Product Launch 2026"));
        await pumpTransition(tester);
      }

      // 9. Back on timeline, verify the node displays with selected emoji and title
      expect(find.text("Summit Friction"), findsOneWidget);
      expect(find.text("🧗"), findsOneWidget);
    });

    testWidgets("Marcus's Path - Manual entry, Detail review, overrides, and AI re-analysis", (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Setup: Create a plotline to start with
      final initialPlotline = Plotline(
        id: 'plot_marcus',
        title: 'Fantasy Novel WIP',
        emoji: '📚',
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );
      plotlineRepo.plotlines.add(initialPlotline);
      configNotifier.setApiKey("AIzaSyMarcusKey"); // Preconfigure API key

      await tester.pumpWidget(createTestApp());
      await pumpTransition(tester);

      final container = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));

      // Tap Fantasy Novel WIP to go to details
      await tester.tap(find.text("Fantasy Novel WIP"));
      await pumpTransition(tester);

      // 1. Open manual entry editor
      await tester.tap(find.byIcon(Icons.edit_note));
      await pumpTransition(tester);

      expect(find.text("New Entry"), findsOneWidget);

      // 2. Draft entry and save
      await tester.enterText(
        find.byType(TextField),
        "Finally broke through the chapter 4 block. Protagonist finds obsidian key guarded by Aether.",
      );
      await tester.tap(find.text("Save"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      await pumpTransition(tester);

      // 3. Select suggested emoji '🌳' (weeping willow)
      expect(find.text("🌳"), findsOneWidget);
      await tester.tap(find.text("🌳"));
      await pumpTransition(tester);

      // Defensively check if we popped back to Library screen, and navigate back to details if needed
      final currentLoc = container.read(routerProvider).routerDelegate.currentConfiguration.uri.toString();
      if (currentLoc == '/') {
        await tester.tap(find.text("Fantasy Novel WIP"));
        await pumpTransition(tester);
      }

      // 4. Back on Plotline detail screen, open the newly created session
      expect(find.text("obsidian key under the willow"), findsOneWidget);
      await tester.tap(find.text("obsidian key under the willow"));
      await pumpTransition(tester);

      // 5. In-place title override
      await tester.tap(find.byIcon(Icons.edit_outlined).first); // Edit title
      await pumpTransition(tester);

      await tester.enterText(find.widgetWithText(TextField, "obsidian key under the willow"), "The Willow's Witness");
      await tester.tap(find.text("Save"));
      await pumpTransition(tester);

      expect(find.text("The Willow's Witness"), findsOneWidget);

      // 6. In-place summary override
      await tester.tap(find.text("Protagonist finds an obsidian key in a weeping willow guarded by a falcon."));
      await pumpTransition(tester);

      await tester.enterText(
        find.widgetWithText(TextField, "Protagonist finds an obsidian key in a weeping willow guarded by a falcon."),
        "Discovering the secret key under the weeping willow, guarded by the silent watcher, Aether.",
      );
      await tester.tap(find.text("Save"));
      await pumpTransition(tester);

      expect(find.text("Discovering the secret key under the weeping willow, guarded by the silent watcher, Aether."), findsOneWidget);

      // 7. Edit transcript (change falcon to owl) and Re-analyze
      await tester.tap(find.text("Finally broke through the chapter 4 block. Protagonist finds obsidian key guarded by Aether."));
      await pumpTransition(tester);

      await tester.enterText(
        find.byType(TextField).last,
        "Finally broke through the chapter 4 block. Protagonist finds obsidian key guarded by blind owl Aether.",
      );
      await tester.tap(find.text("Save"));
      await pumpTransition(tester);

      // Tap Psychology button to re-analyze
      await tester.tap(find.byIcon(Icons.psychology));
      await tester.pump();
      expect(find.text("Narrative Engine weaving your story..."), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 20));
      await pumpTransition(tester);

      // 8. Open Emoji Studio to select new owl emoji
      await tester.tap(find.text("🔑")); // tap hero symbol (first suggested emoji in re-analysis)
      await pumpTransition(tester);

      expect(find.text("🦉"), findsOneWidget);
      await tester.tap(find.text("🦉"));
      await pumpTransition(tester);

      // Verify the hero symbol updates on the session detail screen
      expect(find.text("🦉"), findsOneWidget);
    });

    testWidgets("Elena's Path - Emotional timeline, Emoji tuning, and rate limiting cooldown", (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Setup: Create a plotline and pre-populate sessions with diverse mood scores
      final plotline = Plotline(
        id: 'plot_elena',
        title: 'Caring for Mom',
        emoji: '❤️',
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );
      plotlineRepo.plotlines.add(plotline);

      final oldSession = Session(
        id: 'session_old',
        plotlineId: plotline.id,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        transcript: 'Stressed about doctor appointments and diagnosis.',
        title: 'Diagnosis Anxiety',
        summary: 'High anxiety during diagnosis.',
        moodKeyword: 'Anxious',
        moodScore: -0.8,
        emojis: ['🏡', '💔'],
        selectedEmoji: '🏡',
        type: SessionType.manual,
      );
      final newSession = Session(
        id: 'session_new',
        plotlineId: plotline.id,
        createdAt: DateTime.now(),
        transcript: 'Relief after securing stable care.',
        title: 'Stable Care Secured',
        summary: 'Relief after securing stable care.',
        moodKeyword: 'Relieved',
        moodScore: 0.7,
        emojis: ['💚', '✨'],
        selectedEmoji: '💚',
        type: SessionType.manual,
      );

      sessionRepo.sessions.addAll([oldSession, newSession]);
      configNotifier.setApiKey("AIzaSyElenaKey");

      await tester.pumpWidget(createTestApp());
      await pumpTransition(tester);

      // Go to Caring for Mom plotline
      await tester.tap(find.text("Caring for Mom"));
      await pumpTransition(tester);

      // Verify old session and new session render on the timeline
      expect(find.text("Diagnosis Anxiety"), findsOneWidget);
      expect(find.text("Stable Care Secured"), findsOneWidget);

      // Open Diagnosis Anxiety session
      await tester.tap(find.text("Diagnosis Anxiety"));
      await pumpTransition(tester);

      // Tap on current hero emoji '🏡' to open Emoji Studio
      await tester.tap(find.text("🏡"));
      await pumpTransition(tester);

      // Tap Search Emoji to search manually
      await tester.tap(find.text("Search Emoji"));
      await pumpTransition(tester);

      // Select '❤️' from the picker directly
      final picker = tester.widget<EmojiPicker>(find.byType(EmojiPicker));
      picker.onEmojiSelected!(null, const Emoji('❤️', 'heart'));
      await pumpTransition(tester);

      // Verify selected emoji updates on the detail page
      expect(find.text("❤️"), findsOneWidget);

      // Rate limit test: Simulate 5 previous requests, so 6th throws RateLimitException
      analysisService.callCount = 5;

      // Tap Re-analyze with AI button to trigger the rate limiter
      await tester.tap(find.byIcon(Icons.psychology));
      await pumpTransition(tester);

      // Verify purple "Take a Breath" dialog pops up
      expect(find.text("Take a Breath"), findsOneWidget);
      expect(find.text("Take a deep breath. You are reflecting too quickly. Please wait a moment before analyzing again."), findsOneWidget);

      // Acknowledge the warning to close dialog
      await tester.tap(find.text("Acknowledge"));
      await pumpTransition(tester);

      expect(find.text("Take a Breath"), findsNothing);
    });
  });
}
