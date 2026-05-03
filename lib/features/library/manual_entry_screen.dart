import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/plotline.dart';
import '../../repositories/plotline_repository.dart';

class ManualEntryScreen extends ConsumerStatefulWidget {
  final Plotline? initialPlotline;
  
  const ManualEntryScreen({super.key, this.initialPlotline});

  @override
  ConsumerState<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends ConsumerState<ManualEntryScreen> {
  final _contentController = TextEditingController();
  Plotline? _selectedPlotline;

  @override
  void initState() {
    super.initState();
    _selectedPlotline = widget.initialPlotline;
  }

  void _saveEntry() async {
    if (_contentController.text.isEmpty || _selectedPlotline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a plotline and write something.")),
      );
      return;
    }

    // TODO: Implement Session saving via a SessionRepository
    // For now, we'll just simulate a save
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Entry saved to narrative.")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Entry"),
        actions: [
          TextButton(
            onPressed: _saveEntry,
            child: const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Plotline Selector (Simplified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_stories, color: Colors.white54),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedPlotline?.title ?? "Select Plotline...",
                      style: TextStyle(
                        color: _selectedPlotline == null ? Colors.white38 : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.white54),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                style: const TextStyle(fontSize: 18, height: 1.5),
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
