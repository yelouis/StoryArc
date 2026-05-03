import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/plotline.dart';
import '../../../repositories/plotline_repository.dart';
import 'package:uuid/uuid.dart';

class AddPlotlineScreen extends ConsumerStatefulWidget {
  const AddPlotlineScreen({super.key});

  @override
  ConsumerState<AddPlotlineScreen> createState() => _AddPlotlineScreenState();
}

class _AddPlotlineScreenState extends ConsumerState<AddPlotlineScreen> {
  final _titleController = TextEditingController();
  String _selectedEmoji = "📖";

  void _savePlotline() async {
    if (_titleController.text.isEmpty) return;

    final newPlotline = Plotline(
      id: const Uuid().v4(),
      title: _titleController.text,
      emoji: _selectedEmoji,
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    );

    try {
      await ref.read(plotlineRepositoryProvider).addPlotline(newPlotline);
      if (mounted) Navigator.pop(context);
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
        actions: [
          IconButton(
            onPressed: _savePlotline,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What's the name of this story?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Enter title...",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "Pick a symbolic anchor (Emoji)",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // TODO: Open Emoji Picker
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        _selectedEmoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    "Tap to change. This icon will represent your plotline in the library.",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
