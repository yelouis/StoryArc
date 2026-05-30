import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config_provider.dart';

final geminiLiveServiceProvider = Provider<GeminiLiveService>((ref) {
  final apiKey = ref.watch(configProvider).geminiApiKey;
  return GeminiLiveService(apiKey ?? '');
});

class GeminiLiveService {
  final String apiKey;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  
  final _audioResponseController = StreamController<Uint8List>.broadcast();
  Stream<Uint8List> get audioResponseStream => _audioResponseController.stream;

  final _textResponseController = StreamController<String>.broadcast();
  Stream<String> get textResponseStream => _textResponseController.stream;

  final List<String> _transcriptParts = [];
  String get fullTranscript => _transcriptParts.join("\n");

  GeminiLiveService(this.apiKey);

  Future<void> connect() async {
    if (apiKey.isEmpty) throw Exception("API Key is missing");

    final uri = Uri.parse(
      'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateContent?key=$apiKey',
    );

    _channel = WebSocketChannel.connect(uri);
    
    // Initial Setup
    final setupMessage = {
      "setup": {
        "model": "models/gemini-1.5-flash",
        "generation_config": {
          "response_modalities": ["audio"],
          "speech_config": {
             "voice_config": {
                "prebuilt_voice_config": {
                   "voice_name": "Puck" // Options: Puck, Charon, Kore, Fenrir, Aoede
                }
             }
          }
        },
        "system_instruction": {
          "parts": [
            {"text": "You are a cinematic biographer. Your goal is to help the user document their life story through reflective, deep, and empathetic conversation. Keep responses concise and focused on the user's narrative."}
          ]
        }
      }
    };

    _channel!.sink.add(jsonEncode(setupMessage));

    _subscription = _channel!.stream.listen((message) {
      _handleMessage(message);
    }, onError: (error) {
      print("WebSocket Error: $error");
    }, onDone: () {
      print("WebSocket Closed");
    });
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      
      // Handle Server Content
      if (data['serverContent'] != null) {
        final serverContent = data['serverContent'];

        // Handle User Content (transcribed user turns returned by the server)
        final userContent = serverContent['userContent'] ?? 
                            serverContent['clientContent'] ?? 
                            serverContent['userTurn'] ?? 
                            serverContent['clientTurn'];
        if (userContent != null && userContent['parts'] != null) {
          for (var part in userContent['parts']) {
            if (part['text'] != null) {
              final text = part['text'];
              _transcriptParts.add("User: $text");
            }
          }
        }

        if (serverContent['modelTurn'] != null) {
          final parts = serverContent['modelTurn']['parts'];
          for (var part in parts) {
            if (part['inlineData'] != null) {
              final mimeType = part['inlineData']['mimeType'];
              if (mimeType == 'audio/pcm') {
                final audioData = base64Decode(part['inlineData']['data']);
                _audioResponseController.add(audioData);
              }
            } else if (part['text'] != null) {
              final text = part['text'];
              _transcriptParts.add("Biographer: $text");
              _textResponseController.add(text);
            }
          }
        }
      }
    } catch (e) {
      print("Error decoding message: $e");
    }
  }

  void sendAudio(Uint8List audioChunk) {
    if (_channel == null) return;

    final message = {
      "realtime_input": {
        "media_chunks": [
          {
            "data": base64Encode(audioChunk),
            "mime_type": "audio/pcm"
          }
        ]
      }
    };

    _channel!.sink.add(jsonEncode(message));
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _audioResponseController.close();
    _textResponseController.close();
  }
}
