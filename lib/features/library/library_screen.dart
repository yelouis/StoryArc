import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/plotline_repository.dart';
import 'widgets/plotline_card.dart';
import '../../../core/theme.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plotlinesAsyncValue = ref.watch(plotlineRepositoryProvider).getPlotlines();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Plotlines"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: "Search narratives...",
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
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
                stream: plotlinesAsyncValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final plotlines = snapshot.data ?? [];

                  if (plotlines.isEmpty) {
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
                            onPressed: () {
                              // Navigate to Add Plotline
                            },
                            child: const Text("New Narrative"),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: plotlines.length,
                    itemBuilder: (context, index) {
                      return PlotlineCard(
                        plotline: plotlines[index],
                        onTap: () {
                          // Navigate to Timeline
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Add Plotline
        },
        backgroundColor: CosmicTheme.accentElectricPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
