import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme.dart';
import '../../services/audio_service.dart';
import '../../services/gemini_live_service.dart';
import '../../models/session.dart';
import '../../repositories/session_repository.dart';
import '../../services/analysis_service.dart';
import '../library/widgets/emoji_studio_widget.dart';
import 'widgets/cosmic_visualizer.dart';

class LiveInterviewScreen extends ConsumerStatefulWidget {
  final String? plotlineId;
  const LiveInterviewScreen({super.key, this.plotlineId});

  @override
  ConsumerState<LiveInterviewScreen> createState() => _LiveInterviewScreenState();
}

class _LiveInterviewScreenState extends ConsumerState<LiveInterviewScreen> {
  bool _isConnecting = true;
  double _amplitude = 0.0;
  String _status = "Initializing...";
  StreamSubscription? _audioSub;
  StreamSubscription? _ampSub;
  StreamSubscription? _geminiSub;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  Future<void> _startSession() async {
    final audio = ref.read(audioServiceProvider);
    final gemini = ref.read(geminiLiveServiceProvider);

    try {
      setState(() => _status = "Connecting to Gemini...");
      await gemini.connect();
      
      setState(() => _status = "Setting up Audio...");
      await audio.initPlayback();
      await audio.startRecording();

      _audioSub = audio.audioStream.listen((chunk) {
        gemini.sendAudio(chunk);
      });

      _ampSub = audio.amplitudeStream.listen((amp) {
        if (mounted) {
          setState(() => _amplitude = amp);
        }
      });

      _geminiSub = gemini.audioResponseStream.listen((chunk) {
        audio.playAudioChunk(chunk);
      });

      setState(() {
        _isConnecting = false;
        _status = "Listening...";
      });
    } catch (e) {
      setState(() => _status = "Error: $e");
    }
  }

  bool _isAnalyzing = false;
  Session? _analyzedSession;

  Future<void> _endSession() async {
    final gemini = ref.read(geminiLiveServiceProvider);
    final transcript = gemini.fullTranscript;
    
    // Stop recording and disconnect immediately to free resources
    ref.read(audioServiceProvider).stopRecording();
    gemini.disconnect();

    if (transcript.isNotEmpty && widget.plotlineId != null) {
      setState(() {
        _isAnalyzing = true;
        _status = "Synthesizing Narrative...";
      });

      final session = Session(
        id: const Uuid().v4(),
        plotlineId: widget.plotlineId!,
        createdAt: DateTime.now(),
        transcript: transcript,
        type: SessionType.voice,
      );

      await ref.read(sessionRepositoryProvider).addSession(session);
      await _triggerAnalysis(session);
    } else {
      if (mounted) context.pop();
    }
  }

  Future<void> _triggerAnalysis(Session session) async {
    final analysisService = ref.read(analysisServiceProvider);
    final sessionRepo = ref.read(sessionRepositoryProvider);

    final result = await analysisService.analyzeTranscript(session.transcript);
    if (result != null) {
      final updatedSession = Session(
        id: session.id,
        plotlineId: session.plotlineId,
        createdAt: session.createdAt,
        transcript: session.transcript,
        title: result.title,
        summary: result.summary,
        moodKeyword: result.moodKeyword,
        moodScore: result.moodScore,
        emojis: result.emojis,
        type: session.type,
      );
      await sessionRepo.addSession(updatedSession);
      
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analyzedSession = updatedSession;
        });
        _showEmojiStudio(updatedSession);
      }
    } else {
      if (mounted) context.pop();
    }
  }

  void _showEmojiStudio(Session session) {
    bool completed = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmojiStudioWidget(
        session: session,
        onComplete: () {
          completed = true;
          Navigator.pop(context); // Close bottom sheet
          if (mounted) Navigator.pop(this.context); // Exit LiveInterviewScreen
        },
      ),
    ).then((_) {
      // If they dismissed the bottom sheet without picking, just pop the screen
      if (mounted && !completed && _analyzedSession != null) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _audioSub?.cancel();
    _ampSub?.cancel();
    _geminiSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosmicTheme.backgroundMidnightBlack,
      body: Stack(
        children: [
          // Cosmic Visualizer
          CosmicVisualizer(level: _amplitude),
          
          // UI Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: _endSession,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _status,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 48), // Spacer
                    ],
                  ),
                  const Spacer(),
                  if (_isAnalyzing)
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(CosmicTheme.accentSoftCyan),
                      ),
                    ).animate().fadeIn()
                  else
                    Text(
                      "Speak your truth.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ).animate().fadeIn(duration: 1000.ms),
                  const SizedBox(height: 12),
                  Text(
                    _isAnalyzing 
                      ? "The Biographer is distilling your narrative into symbolic anchors..."
                      : "The Biographer is listening and weaving your narrative.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white38, fontSize: 14),
                  ).animate().fadeIn(delay: 500.ms),
                  const Spacer(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
