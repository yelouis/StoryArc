import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme.dart';
import '../../../models/plotline.dart';
import 'package:intl/intl.dart';

class PlotlineCard extends StatelessWidget {
  final Plotline plotline;
  final VoidCallback onTap;
  final VoidCallback onPinToggle;

  const PlotlineCard({
    super.key,
    required this.plotline,
    required this.onTap,
    required this.onPinToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CosmicTheme.glassWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: CosmicTheme.accentElectricPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  plotline.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plotline.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Last active: ${DateFormat('MMM d, h:mm a').format(plotline.lastActive)}",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                plotline.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: plotline.isPinned ? CosmicTheme.accentElectricPurple : Colors.white24,
                size: 20,
              ),
              onPressed: onPinToggle,
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white54,
            ),
          ],
        ),
      )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .shimmer(duration: 3.seconds, color: Colors.white10)
          .animate()
          .fadeIn(duration: 400.ms)
          .slideX(begin: 0.1)
          .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1.0, 1.0),
            duration: 400.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}
