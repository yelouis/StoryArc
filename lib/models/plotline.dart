import 'package:cloud_firestore/cloud_firestore.dart';

enum PlotlineStatus { active, archived, completed }

class Plotline {
  final String id;
  final String title;
  final String emoji;
  final String description;
  final PlotlineStatus status;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime lastActive;

  Plotline({
    required this.id,
    required this.title,
    required this.emoji,
    this.description = '',
    this.status = PlotlineStatus.active,
    this.isPinned = false,
    required this.createdAt,
    required this.lastActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'emoji': emoji,
      'description': description,
      'status': status.name,
      'isPinned': isPinned,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
    };
  }

  factory Plotline.fromMap(Map<String, dynamic> map) {
    return Plotline(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      emoji: map['emoji'] ?? '📖',
      description: map['description'] ?? '',
      status: PlotlineStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PlotlineStatus.active,
      ),
      isPinned: map['isPinned'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastActive: (map['lastActive'] as Timestamp).toDate(),
    );
  }
}
