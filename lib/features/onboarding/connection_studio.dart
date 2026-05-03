import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/config_provider.dart';
import '../../core/widgets/arc_widgets.dart';

class ConnectionStudioScreen extends ConsumerStatefulWidget {
  const ConnectionStudioScreen({super.key});

  @override
  ConsumerState<ConnectionStudioScreen> createState() => _ConnectionStudioScreenState();
}

class _ConnectionStudioScreenState extends ConsumerState<ConnectionStudioScreen> {
  final _apiKeyController = TextEditingController();
  bool _isObscured = true;
  bool _isValidating = false;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _handleTestConnection() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter an API key"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isValidating = true);

    // Mock validation logic
    await Future.delayed(const Duration(seconds: 1));

    if (key.startsWith("AIza")) {
      await ref.read(configProvider.notifier).setApiKey(key);
      if (mounted) {
        context.go('/');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid API key format. Should start with 'AIza'."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }

    setState(() => _isValidating = false);
  }

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
                ArcTextField(
                  controller: _apiKeyController,
                  label: "Gemini API Key",
                  hint: "Enter your API key...",
                  obscureText: _isObscured,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white70,
                    ),
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  ),
                ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.95, 0.95)),
                const SizedBox(height: 24),
                ArcButton(
                  text: "Test Connection",
                  onPressed: _handleTestConnection,
                  isLoading: _isValidating,
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
