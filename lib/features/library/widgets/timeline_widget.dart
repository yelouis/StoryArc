import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/session.dart';
import '../../../core/utils/mood_color_mapper.dart';

class TimelineWidget extends StatelessWidget {
  final List<Session> sessions;
  final Function(Session) onSessionTap;

  const TimelineWidget({
    super.key,
    required this.sessions,
    required this.onSessionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Center(
        child: Text(
          "No narrative chapters yet.\nBegin your journey.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 16,
            fontFamily: 'Outfit',
          ),
        ),
      );
    }

    // Sort sessions by date (reverse chronological as per Phase 3 docs)
    final sortedSessions = List<Session>.from(sessions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      itemCount: sortedSessions.length,
      itemBuilder: (context, index) {
        final session = sortedSessions[index];
        final moodColor = MoodColorMapper.getColor(session.moodScore);
        final isLast = index == sortedSessions.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline line and node
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: moodColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: moodColor.withOpacity(0.5), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: moodColor.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        session.selectedEmoji ?? (session.emojis.isNotEmpty ? session.emojis.first : '✦'),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              moodColor,
                              MoodColorMapper.getColor(sortedSessions[index + 1].moodScore),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Session Content
              Expanded(
                child: GestureDetector(
                  onTap: () => onSessionTap(session),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              DateFormat('MMM d, yyyy • HH:mm').format(session.createdAt),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          session.title ?? 'A Quiet Moment',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          session.summary ?? 'The story remains to be told...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            height: 1.5,
                            fontStyle: session.summary == null ? FontStyle.italic : FontStyle.normal,
                          ),
                        ),
                        if (session.moodKeyword != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: moodColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: moodColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              session.moodKeyword!,
                              style: TextStyle(
                                color: moodColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
