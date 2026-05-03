import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';

class ConnectionStudioScreen extends ConsumerStatefulWidget {
  const ConnectionStudioScreen({super.key});

  @override
  ConsumerState<ConnectionStudioScreen> createState() => _ConnectionStudioScreenState();
}

class _ConnectionStudioScreenState extends ConsumerState<ConnectionStudioScreen> {
  final _apiKeyController = TextEditingController();
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              CosmicTheme.primaryDeepIndigo,
              CosmicTheme.backgroundMidnightBlack,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                Text(
                  "Connection Studio",
                  style: Theme.of(context).textTheme.displayLarge,
                ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2),
                const SizedBox(height: 12),
                Text(
                  "Bring your own AI. Connect your Gemini API key to start your cinematic journey.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ).animate().fadeIn(delay: 200.ms, duration: 800.ms),
                const Spacer(),
                TextField(
                  controller: _apiKeyController,
                  obscureText: _isObscured,
                  decoration: InputDecoration(
                    labelText: "Gemini API Key",
                    hintText: "Enter your API key...",
                    filled: true,
                    fillColor: CosmicTheme.glassWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: () => setState(() => _isObscured = !_isObscured),
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.95, 0.95)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement validation logic
                    },
                    child: const Text("Test Connection"),
                  ),
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
