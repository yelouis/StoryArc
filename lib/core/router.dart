import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/library/library_screen.dart';
import 'features/library/add_plotline_screen.dart';
import 'features/library/manual_entry_screen.dart';
import 'features/library/plotline_detail_screen.dart';
import 'features/onboarding/connection_studio.dart';
import 'features/onboarding/onboarding_prologue.dart';
import 'features/live_session/live_interview_screen.dart';
import 'core/config_provider.dart';
import 'models/plotline.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final config = ref.watch(configProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isConfigured = config.geminiApiKey != null && config.geminiApiKey!.isNotEmpty;
      final isGoingToOnboarding = state.matchedLocation == '/onboarding' || state.matchedLocation == '/connection-studio';

      if (!isConfigured && !isGoingToOnboarding) {
        return '/onboarding';
      }
      if (isConfigured && isGoingToOnboarding) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LibraryScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPrologueScreen(),
      ),
      GoRoute(
        path: '/connection-studio',
        builder: (context, state) => const ConnectionStudioScreen(),
      ),
      GoRoute(
        path: '/add-plotline',
        builder: (context, state) => const AddPlotlineScreen(),
      ),
      GoRoute(
        path: '/manual-entry',
        builder: (context, state) => ManualEntryScreen(initialPlotline: state.extra as Plotline?),
      ),
      GoRoute(
        path: '/plotline-detail',
        builder: (context, state) => PlotlineDetailScreen(plotline: state.extra as Plotline),
      ),
      GoRoute(
        path: '/live-session',
        builder: (context, state) => LiveInterviewScreen(plotlineId: state.extra as String?),
      ),
    ],
  );
});
