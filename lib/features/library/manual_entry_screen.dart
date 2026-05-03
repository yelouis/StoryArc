import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../models/session.dart';
import '../../models/plotline.dart';
import '../../repositories/session_repository.dart';
import '../../repositories/plotline_repository.dart';
import '../../services/analysis_service.dart';
import 'widgets/emoji_studio_widget.dart';
import '../../../core/theme.dart';

class ManualEntryScreen extends ConsumerStatefulWidget {
  final Plotline? initialPlotline;

  const ManualEntryScreen({super.key, this.initialPlotline});

  @override
  ConsumerState<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends ConsumerState<ManualEntryScreen> {
  final _contentController = TextEditingController();
  Plotline? _selectedPlotline;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedPlotline = widget.initialPlotline;
  }

  void _showPlotlineSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final plotlinesStream = ref.watch(plotlineRepositoryProvider).getPlotlines();
            return StreamBuilder<List<Plotline>>(
              stream: plotlinesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final plotlines = snapshot.data!;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        "Assign to Plotline",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: plotlines.length,
                        itemBuilder: (context, index) {
                          final p = plotlines[index];
                          return ListTile(
                            leading: Text(p.emoji, style: const TextStyle(fontSize: 24)),
                            title: Text(p.title, style: const TextStyle(color: Colors.white)),
                            onTap: () {
                              setState(() => _selectedPlotline = p);
                              Navigator.pop(context);
                            },
                            trailing: _selectedPlotline?.id == p.id
                                ? const Icon(Icons.check, color: CosmicTheme.accentElectricPurple)
                                : null,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _saveEntry() async {
    if (_contentController.text.isEmpty || _selectedPlotline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a plotline and write something.")),
      );
      return;
    }

    setState(() => _isSaving = true);

    final session = Session(
      id: const Uuid().v4(),
      transcript: _contentController.text,
      createdAt: DateTime.now(),
      plotlineId: _selectedPlotline!.id,
      type: SessionType.manual,
    );

    try {
      final sessionRepo = ref.read(sessionRepositoryProvider);
      await sessionRepo.addSession(session);
      
      // Wait for AI Analysis to present Emoji Studio
      final updatedSession = await _triggerAnalysis(session);
      
      if (mounted && updatedSession != null) {
        _showEmojiStudio(updatedSession);
      } else if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<Session?> _triggerAnalysis(Session session) async {
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
      return updatedSession;
    }
    return null;
  }

  void _showEmojiStudio(Session session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmojiStudioWidget(
        session: session,
        onComplete: () {
          Navigator.pop(context); // Close bottom sheet
          if (mounted) Navigator.pop(this.context); // Exit ManualEntryScreen
        },
      ),
    ).then((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Entry"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else
            TextButton(
              onPressed: _saveEntry,
              child: const Text(
                "Save",
                style: TextStyle(color: CosmicTheme.accentElectricPurple, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _showPlotlineSelector,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: CosmicTheme.glassWhite,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedPlotline?.emoji ?? "📖",
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedPlotline?.title ?? "Select Plotline...",
                        style: TextStyle(
                          color: _selectedPlotline == null ? Colors.white38 : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                style: const TextStyle(fontSize: 18, height: 1.6, color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  hintStyle: TextStyle(color: Colors.white24),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
