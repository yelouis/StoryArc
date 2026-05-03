import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  
  StreamSubscription<Uint8List>? _recordSubscription;
  final _audioStreamController = StreamController<Uint8List>.broadcast();
  
  Stream<Uint8List> get audioStream => _audioStreamController.stream;
  
  // For visualizer
  final _amplitudeController = StreamController<double>.broadcast();
  Stream<double> get amplitudeStream => _amplitudeController.stream;
  Timer? _amplitudeTimer;

  Future<void> startRecording() async {
    if (await _recorder.hasPermission()) {
      const config = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      );

      final stream = await _recorder.startStream(config);
      
      _recordSubscription = stream.listen((data) {
        _audioStreamController.add(Uint8List.fromList(data));
      });

      _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
        final amp = await _recorder.getAmplitude();
        // Convert decibels to a 0.0 - 1.0 range roughly
        double normalized = (amp.current + 60) / 60;
        normalized = normalized.clamp(0.0, 1.0);
        _amplitudeController.add(normalized);
      });
    }
  }

  Future<void> stopRecording() async {
    await _recordSubscription?.cancel();
    _amplitudeTimer?.cancel();
    await _recorder.stop();
  }

  Future<void> initPlayback() async {
    await FlutterPcmSound.setup(sampleRate: 16000, channels: 1);
  }

  Future<void> playAudioChunk(Uint8List chunk) async {
    // Gemini returns 16-bit PCM. flutter_pcm_sound expects Int16List or Uint8List depending on version.
    await FlutterPcmSound.feed(chunk);
  }

  void dispose() {
    _recorder.dispose();
    _player.dispose();
    _recordSubscription?.cancel();
    _amplitudeTimer?.cancel();
    _audioStreamController.close();
    _amplitudeController.close();
    FlutterPcmSound.release();
  }
}
