import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../services/audio_service.dart';
import '../../services/gemini_live_service.dart';
import 'widgets/cosmic_visualizer.dart';

class LiveInterviewScreen extends ConsumerStatefulWidget {
  const LiveInterviewScreen({super.key});

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

  void _endSession() {
    ref.read(audioServiceProvider).stopRecording();
    ref.read(geminiLiveServiceProvider).disconnect();
    context.pop();
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
                  Text(
                    "Speak your truth.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ).animate().fadeIn(duration: 1000.ms),
                  const SizedBox(height: 12),
                  const Text(
                    "The Biographer is listening and weaving your narrative.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 14),
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
