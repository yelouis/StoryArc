import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/library/library_screen.dart';
import 'features/library/add_plotline_screen.dart';
import 'features/library/manual_entry_screen.dart';
import 'features/onboarding/connection_studio.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LibraryScreen(),
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
      builder: (context, state) => const ManualEntryScreen(),
    ),
  ],
);
