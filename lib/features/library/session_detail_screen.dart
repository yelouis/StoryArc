import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/session.dart';
import '../../repositories/session_repository.dart';
import '../../services/analysis_service.dart';
import '../../core/theme.dart';
import '../../core/utils/mood_color_mapper.dart';
import 'widgets/emoji_studio_widget.dart';

class SessionDetailScreen extends ConsumerStatefulWidget {
  final Session session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  ConsumerState<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen> {
  late Session _session;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
  }

  Future<void> _updateSession(Session updatedSession) async {
    try {
      await ref.read(sessionRepositoryProvider).addSession(updatedSession);
      setState(() {
        _session = updatedSession;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save changes: $e")),
        );
      }
    }
  }

  void _editTitle() {
    final controller = TextEditingController(text: _session.title ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161625),
        title: const Text("Edit Title", style: TextStyle(fontFamily: 'Outfit', color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter title...",
            hintStyle: TextStyle(color: Colors.white30),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: CosmicTheme.accentElectricPurple)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (controller.text.trim().isNotEmpty) {
                final updated = Session(
                  id: _session.id,
                  plotlineId: _session.plotlineId,
                  createdAt: _session.createdAt,
                  transcript: _session.transcript,
                  title: controller.text.trim(),
                  summary: _session.summary,
                  moodKeyword: _session.moodKeyword,
                  moodScore: _session.moodScore,
                  emojis: _session.emojis,
                  selectedEmoji: _session.selectedEmoji,
                  type: _session.type,
                );
                _updateSession(updated);
              }
            },
            child: const Text("Save", style: TextStyle(color: CosmicTheme.accentElectricPurple, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _editSummary() {
    final controller = TextEditingController(text: _session.summary ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161625),
        title: const Text("Edit Summary", style: TextStyle(fontFamily: 'Outfit', color: Colors.white)),
        content: TextField(
          controller: controller,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter summary...",
            hintStyle: TextStyle(color: Colors.white30),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: CosmicTheme.accentElectricPurple)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final updated = Session(
                id: _session.id,
                plotlineId: _session.plotlineId,
                createdAt: _session.createdAt,
                transcript: _session.transcript,
                title: _session.title,
                summary: controller.text.trim().isEmpty ? null : controller.text.trim(),
                moodKeyword: _session.moodKeyword,
                moodScore: _session.moodScore,
                emojis: _session.emojis,
                selectedEmoji: _session.selectedEmoji,
                type: _session.type,
              );
              _updateSession(updated);
            },
            child: const Text("Save", style: TextStyle(color: CosmicTheme.accentElectricPurple, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _editTranscript() {
    final controller = TextEditingController(text: _session.transcript);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161625),
        title: const Text("Edit Transcript", style: TextStyle(fontFamily: 'Outfit', color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            maxLines: 12,
            style: const TextStyle(color: Colors.white, height: 1.5),
            decoration: const InputDecoration(
              hintText: "Write your transcript...",
              hintStyle: TextStyle(color: Colors.white30),
              border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: CosmicTheme.accentElectricPurple)),
            ),
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (controller.text.trim().isNotEmpty) {
                final updated = Session(
                  id: _session.id,
                  plotlineId: _session.plotlineId,
                  createdAt: _session.createdAt,
                  transcript: controller.text.trim(),
                  title: _session.title,
                  summary: _session.summary,
                  moodKeyword: _session.moodKeyword,
                  moodScore: _session.moodScore,
                  emojis: _session.emojis,
                  selectedEmoji: _session.selectedEmoji,
                  type: _session.type,
                );
                _updateSession(updated);
              }
            },
            child: const Text("Save", style: TextStyle(color: CosmicTheme.accentElectricPurple, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openEmojiStudio() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmojiStudioWidget(
        session: _session,
        onComplete: () {
          Navigator.pop(context); // Close bottom sheet
          // Reload local state from firestore/database if needed, or simply let the repository set trigger refresh
        },
      ),
    ).then((_) {
      // Fetch latest document status
      ref.read(sessionRepositoryProvider).getSessions(_session.plotlineId).first.then((list) {
        final current = list.firstWhere((s) => s.id == _session.id, orElse: () => _session);
        if (mounted) {
          setState(() {
            _session = current;
          });
        }
      });
    });
  }

  Future<void> _reanalyzeWithAI() async {
    setState(() => _isAnalyzing = true);

    try {
      final analysisService = ref.read(analysisServiceProvider);
      final result = await analysisService.analyzeTranscript(_session.transcript);

      if (result != null) {
        final updated = Session(
          id: _session.id,
          plotlineId: _session.plotlineId,
          createdAt: _session.createdAt,
          transcript: _session.transcript,
          title: result.title,
          summary: result.summary,
          moodKeyword: result.moodKeyword,
          moodScore: result.moodScore,
          emojis: result.emojis,
          selectedEmoji: result.emojis.isNotEmpty ? result.emojis.first : null,
          type: _session.type,
        );
        await _updateSession(updated);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("AI Analysis completed successfully!")),
          );
        }
      } else {
        throw Exception("Gemini returned empty results.");
      }
    } catch (e) {
      if (mounted) {
        if (e is RateLimitException) {
          _showRateLimitDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("AI Analysis failed: $e")),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _showRateLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E102E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.hourglass_empty, color: Colors.amberAccent),
            SizedBox(width: 12),
            Text("Take a Breath", style: TextStyle(fontFamily: 'Outfit', color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "Take a deep breath. You are reflecting too quickly. Please wait a moment before analyzing again.",
          style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Acknowledge", style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final moodColor = MoodColorMapper.getColor(_session.moodScore);
    final formattedDate = DateFormat('MMMM d, yyyy • HH:mm').format(_session.createdAt);

    return Scaffold(
      backgroundColor: CosmicTheme.backgroundMidnightBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _session.type == SessionType.voice ? "Voice Reflection" : "Manual Reflection",
          style: const TextStyle(fontSize: 16, color: Colors.white54, letterSpacing: 1.2),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology, color: CosmicTheme.accentElectricPurple),
            tooltip: "Re-analyze with AI",
            onPressed: _isAnalyzing ? null : _reanalyzeWithAI,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Emoji Symbolic Anchor
                Center(
                  child: GestureDetector(
                    onTap: _openEmojiStudio,
                    child: Hero(
                      tag: 'emoji_${_session.id}',
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: moodColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: moodColor.withOpacity(0.4), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: moodColor.withOpacity(0.25),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _session.selectedEmoji ?? (_session.emojis.isNotEmpty ? _session.emojis.first : '✦'),
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    "Tap symbol to change",
                    style: TextStyle(color: Colors.white30, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 32),

                // Date & Time
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),

                // Title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _session.title ?? 'Untitled Journey',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                          height: 1.3,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.white38),
                      onPressed: _editTitle,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Mood Indicator details
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: moodColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: moodColor.withOpacity(0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: moodColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _session.moodKeyword ?? 'Neutral',
                            style: TextStyle(
                              color: moodColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Sentiment: ${(_session.moodScore >= 0 ? '+' : '')}${_session.moodScore.toStringAsFixed(2)}",
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Summary Card
                const Text(
                  "Narrative Arc Summary",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _editSummary,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: CosmicTheme.glassWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _session.summary ?? 'Tap to write a short, cinematic summary for this reflection...',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 15,
                              height: 1.6,
                              fontStyle: _session.summary == null ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.edit_outlined, size: 18, color: Colors.white30),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Full Transcript
                const Text(
                  "Journal Log",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _editTranscript,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${_session.transcript.split(' ').length} words",
                              style: const TextStyle(color: Colors.white38, fontSize: 12),
                            ),
                            const Icon(Icons.edit_outlined, size: 18, color: Colors.white30),
                          ],
                        ),
                        const Divider(color: Colors.white10, height: 24),
                        Text(
                          _session.transcript,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 16,
                            height: 1.7,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
          if (_isAnalyzing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: CosmicTheme.accentElectricPurple,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Narrative Engine weaving your story...",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
