import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/widgets/arc_widgets.dart';

class OnboardingPrologueScreen extends StatelessWidget {
  const OnboardingPrologueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
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
                const SizedBox(height: 80),
                const Icon(
                  Icons.auto_stories,
                  color: CosmicTheme.accentElectricPurple,
                  size: 48,
                ).animate().fadeIn(duration: 800.ms).scale(),
                const SizedBox(height: 32),
                Text(
                  "Life is a series of\ninterwoven narratives.",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 32,
                    height: 1.2,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideY(begin: 0.1),
                const SizedBox(height: 16),
                Text(
                  "We call them Plotlines. They are the recurring themes, the major arcs, and the subtle shifts that define who you are.",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
                const Spacer(),
                ArcCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Your Story, Your Sovereignty",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "StoryArc is built on the principle of data sovereignty. Bring your own AI credentials to maintain full control over your narrative journey.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                const SizedBox(height: 32),
                ArcButton(
                  text: "Begin My Journey",
                  onPressed: () => context.go('/connection-studio'),
                ).animate().fadeIn(delay: 800.ms),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
