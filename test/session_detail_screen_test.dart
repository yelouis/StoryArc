import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_arc/features/library/session_detail_screen.dart';
import 'package:story_arc/models/session.dart';
import 'package:story_arc/repositories/session_repository.dart';
import 'package:story_arc/services/analysis_service.dart';

// Fakes & Mocks
class FakeUser {}

class FakeAuthService {
  dynamic get currentUser => FakeUser();
}

class MockSessionRepository extends SessionRepository {
  final List<Session> sessions = [];

  MockSessionRepository() : super(FakeAuthService() as dynamic);

  @override
  Stream<List<Session>> getSessions(String plotlineId) {
    return Stream.value(sessions.where((s) => s.plotlineId == plotlineId).toList());
  }

  @override
  Future<void> addSession(Session session) async {
    sessions.removeWhere((s) => s.id == session.id);
    sessions.add(session);
  }
}

class MockAnalysisService extends AnalysisService {
  MockAnalysisService() : super('mock_api_key');

  @override
  Future<AnalysisResult?> analyzeTranscript(String transcript) async {
    return AnalysisResult(
      title: 'Mock AI Title',
      summary: 'Mock AI Summary',
      moodKeyword: 'Inspired',
      moodScore: 0.9,
      emojis: ['💡', '✍️', '✨'],
    );
  }
}

void main() {
  late Session initialSession;
  late MockSessionRepository mockSessionRepo;
  late MockAnalysisService mockAnalysisService;

  setUp(() {
    initialSession = Session(
      id: 'session_123',
      plotlineId: 'plot_123',
      createdAt: DateTime(2026, 5, 27, 20, 0),
      transcript: 'This is a test transcript of my journaling session.',
      title: 'Test Session Title',
      summary: 'A test session summary.',
      moodKeyword: 'Neutral',
      moodScore: 0.0,
      emojis: ['📖'],
      selectedEmoji: '📖',
      type: SessionType.manual,
    );

    mockSessionRepo = MockSessionRepository()..sessions.add(initialSession);
    mockAnalysisService = MockAnalysisService();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        sessionRepositoryProvider.overrideWithValue(mockSessionRepo),
        analysisServiceProvider.overrideWithValue(mockAnalysisService),
      ],
      child: MaterialApp(
        home: SessionDetailScreen(session: initialSession),
      ),
    );
  }

  group('SessionDetailScreen Widget Tests', () {
    testWidgets('Renders all session metadata correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify title is rendered
      expect(find.text('Test Session Title'), findsOneWidget);

      // Verify mood keyword is rendered
      expect(find.text('Neutral'), findsOneWidget);

      // Verify summary is rendered
      expect(find.text('A test session summary.'), findsOneWidget);

      // Verify transcript is rendered
      expect(find.text('This is a test transcript of my journaling session.'), findsOneWidget);
    });

    testWidgets('Tapping title edit icon opens edit dialog', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap the first edit icon (the title edit)
      final editIcon = find.byIcon(Icons.edit_outlined).first;
      await tester.tap(editIcon);
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Edit Title'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Test Session Title'), findsOneWidget);
    });

    testWidgets('Tapping re-analyze with AI button triggers re-analysis', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap the Psychology button in the AppBar
      final reanalyzeButton = find.byIcon(Icons.psychology);
      await tester.tap(reanalyzeButton);
      await tester.pump(); // Start async action

      // Verify cinematic loading text shows
      expect(find.text('Narrative Engine weaving your story...'), findsOneWidget);

      await tester.pumpAndSettle(); // Complete async action

      // Verify loading text goes away
      expect(find.text('Narrative Engine weaving your story...'), findsNothing);

      // Verify updated values from MockAnalysisService are saved and displayed
      expect(find.text('Mock AI Title'), findsOneWidget);
      expect(find.text('Inspired'), findsOneWidget);
      expect(find.text('Mock AI Summary'), findsOneWidget);
    });
  });
}
