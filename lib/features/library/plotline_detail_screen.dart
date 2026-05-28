import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/plotline.dart';
import '../../repositories/session_repository.dart';
import '../../repositories/plotline_repository.dart';
import 'widgets/timeline_widget.dart';
import '../../../core/theme.dart';

class PlotlineDetailScreen extends ConsumerWidget {
  final Plotline plotline;

  const PlotlineDetailScreen({super.key, required this.plotline});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionRepo = ref.watch(sessionRepositoryProvider);
    final plotlineRepo = ref.watch(plotlineRepositoryProvider);
    final sessionsStream = sessionRepo.getSessions(plotline.id);

    return Scaffold(
      backgroundColor: CosmicTheme.backgroundMidnightBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Text(plotline.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                plotline.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              plotline.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: plotline.isPinned ? CosmicTheme.accentElectricPurple : Colors.white54,
            ),
            onPressed: () => plotlineRepo.togglePin(plotline.id, !plotline.isPinned),
          ),
        ],
      ),
      body: Column(
        children: [
          // Plotline Description
          if (plotline.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                plotline.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          
          // Timeline
          Expanded(
            child: StreamBuilder(
              stream: sessionsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final sessions = snapshot.data ?? [];
                return TimelineWidget(
                  sessions: sessions,
                  onSessionTap: (session) {
                    context.push('/session-detail', extra: session);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'voice',
            onPressed: () => context.push('/live-session', extra: plotline.id),
            backgroundColor: CosmicTheme.accentSoftCyan,
            child: const Icon(Icons.mic, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'manual',
            onPressed: () => context.push('/manual-entry', extra: plotline),
            backgroundColor: CosmicTheme.accentElectricPurple,
            child: const Icon(Icons.edit_note, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
