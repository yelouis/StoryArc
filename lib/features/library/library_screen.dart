import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/plotline_repository.dart';
import 'widgets/plotline_card.dart';
import '../../../core/theme.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plotlineRepo = ref.watch(plotlineRepositoryProvider);
    final plotlinesStream = plotlineRepo.getPlotlines();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Plotlines"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.mic, color: CosmicTheme.accentSoftCyan),
            onPressed: () => GoRouter.of(context).push('/live-session'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search narratives...",
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: CosmicTheme.glassWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder(
                stream: plotlinesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final allPlotlines = snapshot.data ?? [];
                  final filteredPlotlines = allPlotlines.where((p) {
                    return p.title.toLowerCase().contains(_searchQuery) ||
                        p.emoji.contains(_searchQuery);
                  }).toList();

                  if (allPlotlines.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_stories, size: 64, color: Colors.white24),
                          const SizedBox(height: 16),
                          const Text(
                            "Start your first Plotline",
                            style: TextStyle(color: Colors.white54, fontSize: 18),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => GoRouter.of(context).push('/add-plotline'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CosmicTheme.accentElectricPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("New Narrative"),
                          ),
                        ],
                      ),
                    );
                  }

                  final pinnedPlotlines = filteredPlotlines.where((p) => p.isPinned).toList();
                  final otherPlotlines = filteredPlotlines.where((p) => !p.isPinned).toList();

                  return ListView(
                    children: [
                      if (pinnedPlotlines.isNotEmpty) ...[
                        const Text(
                          "PINNED",
                          style: TextStyle(
                            color: Colors.white38,
                            letterSpacing: 1.2,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...pinnedPlotlines.map((p) => PlotlineCard(
                              plotline: p,
                              onTap: () => GoRouter.of(context).push('/plotline-detail', extra: p),
                              onPinToggle: () => plotlineRepo.togglePin(p.id, !p.isPinned),
                            )),
                        const SizedBox(height: 24),
                      ],
                      if (otherPlotlines.isNotEmpty) ...[
                        const Text(
                          "ALL NARRATIVES",
                          style: TextStyle(
                            color: Colors.white38,
                            letterSpacing: 1.2,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...otherPlotlines.map((p) => PlotlineCard(
                              plotline: p,
                              onTap: () => GoRouter.of(context).push('/plotline-detail', extra: p),
                              onPinToggle: () => plotlineRepo.togglePin(p.id, !p.isPinned),
                            )),
                      ],
                      if (filteredPlotlines.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Text(
                              "No matching plotlines found.",
                              style: TextStyle(color: Colors.white38),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => GoRouter.of(context).push('/add-plotline'),
        backgroundColor: CosmicTheme.accentElectricPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
