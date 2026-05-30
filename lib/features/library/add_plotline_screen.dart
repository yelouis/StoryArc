import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../models/plotline.dart';
import '../../repositories/plotline_repository.dart';
import '../../core/theme.dart';

class AddPlotlineScreen extends ConsumerStatefulWidget {
  const AddPlotlineScreen({super.key});

  @override
  ConsumerState<AddPlotlineScreen> createState() => _AddPlotlineScreenState();
}

class _AddPlotlineScreenState extends ConsumerState<AddPlotlineScreen> {
  final _titleController = TextEditingController();
  String _selectedEmoji = "📖";
  String _selectedGradient = "Deep Purple";
  bool _showEmojiPicker = false;

  void _savePlotline() async {
    if (_titleController.text.isEmpty) return;

    final newPlotline = Plotline(
      id: const Uuid().v4(),
      title: _titleController.text,
      emoji: _selectedEmoji,
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
      gradientName: _selectedGradient,
    );

    try {
      await ref.read(plotlineRepositoryProvider).addPlotline(newPlotline);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Narrative"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _savePlotline,
            icon: const Icon(Icons.check, color: CosmicTheme.accentElectricPurple),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "What's the name of this story?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    autofocus: true,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter title...",
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: CosmicTheme.glassWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Select a color palette",
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: CosmicTheme.gradients.entries.map((entry) {
                        final name = entry.key;
                        final colors = entry.value;
                        final isSelected = _selectedGradient == name;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedGradient = name;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 16),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: colors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: colors.first.withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Pick a symbolic anchor",
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showEmojiPicker = !_showEmojiPicker;
                          });
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: CosmicTheme.glassWhite,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _showEmojiPicker
                                  ? CosmicTheme.accentElectricPurple
                                  : Colors.white10,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _selectedEmoji,
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Expanded(
                        child: Text(
                          "Tap the icon to choose an emoji that represents this narrative arc.",
                          style: TextStyle(color: Colors.white38, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_showEmojiPicker)
            SizedBox(
              height: 250,
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  setState(() {
                    _selectedEmoji = emoji.emoji;
                    _showEmojiPicker = false;
                  });
                },
                config: Config(
                  columns: 7,
                  emojiSizeMax: 32,
                  verticalSpacing: 0,
                  horizontalSpacing: 0,
                  gridPadding: EdgeInsets.zero,
                  initCategory: Category.RECENT,
                  bgColor: const Color(0xFF1A1A2E),
                  indicatorColor: CosmicTheme.accentElectricPurple,
                  iconColor: Colors.white24,
                  iconColorSelected: CosmicTheme.accentElectricPurple,
                  backspaceColor: CosmicTheme.accentElectricPurple,
                  skinToneDialogBgColor: Colors.white,
                  skinToneIndicatorColor: Colors.grey,
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
        ],
      ),
    );
  }
}
