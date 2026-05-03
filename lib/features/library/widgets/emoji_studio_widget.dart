import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../../models/session.dart';
import '../../../repositories/session_repository.dart';
import '../../../core/theme.dart';

class EmojiStudioWidget extends ConsumerStatefulWidget {
  final Session session;
  final VoidCallback? onComplete;

  const EmojiStudioWidget({
    super.key,
    required this.session,
    this.onComplete,
  });

  @override
  ConsumerState<EmojiStudioWidget> createState() => _EmojiStudioWidgetState();
}

class _EmojiStudioWidgetState extends ConsumerState<EmojiStudioWidget> {
  String? _selectedEmoji;
  bool _showFullPicker = false;

  @override
  void initState() {
    super.initState();
    _selectedEmoji = widget.session.selectedEmoji;
  }

  Future<void> _saveEmoji(String emoji) async {
    setState(() => _selectedEmoji = emoji);
    
    final updatedSession = Session(
      id: widget.session.id,
      plotlineId: widget.session.plotlineId,
      createdAt: widget.session.createdAt,
      transcript: widget.session.transcript,
      title: widget.session.title,
      summary: widget.session.summary,
      moodKeyword: widget.session.moodKeyword,
      moodScore: widget.session.moodScore,
      emojis: widget.session.emojis,
      selectedEmoji: emoji,
      type: widget.session.type,
    );

    await ref.read(sessionRepositoryProvider).addSession(updatedSession);
    
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: CosmicTheme.backgroundMidnightBlack,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Symbolic Anchor",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Select a symbol that captures this chapter.",
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
          const SizedBox(height: 32),
          
          if (!_showFullPicker) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: widget.session.emojis.map((emoji) {
                final isSelected = _selectedEmoji == emoji;
                return GestureDetector(
                  onTap: () => _saveEmoji(emoji),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white10 : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white38 : Colors.white10,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: () => setState(() => _showFullPicker = true),
              icon: const Icon(Icons.search, color: Colors.white70),
              label: const Text(
                "Search Emoji",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ] else ...[
            SizedBox(
              height: 300,
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  _saveEmoji(emoji.emoji);
                },
                config: Config(
                  columns: 7,
                  emojiSizeMax: 32,
                  verticalSpacing: 0,
                  horizontalSpacing: 0,
                  gridPadding: EdgeInsets.zero,
                  initCategory: Category.RECENT,
                  bgColor: Colors.transparent,
                  indicatorColor: Colors.white38,
                  iconColor: Colors.white38,
                  iconColorSelected: Colors.white,
                  backspaceColor: Colors.white,
                  skinToneDialogBgColor: Colors.white,
                  skinToneIndicatorColor: Colors.white,
                  enableSkinTones: true,
                  recentTabBehavior: RecentTabBehavior.RECENT,
                  recentsLimit: 28,
                  noRecents: const Text(
                    'No Recents',
                    style: TextStyle(fontSize: 20, color: Colors.black26),
                    textAlign: TextAlign.center,
                  ),
                  loadingIndicator: const SizedBox.shrink(),
                  tabIndicatorAnimDuration: kTabScrollDuration,
                  categoryIcons: const CategoryIcons(),
                  buttonMode: ButtonMode.MATERIAL,
                ),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _showFullPicker = false),
              child: const Text("Back to Suggestions", style: TextStyle(color: Colors.white38)),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
