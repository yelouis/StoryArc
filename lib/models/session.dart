import 'package:cloud_firestore/cloud_firestore.dart';

enum SessionType { manual, voice }

class Session {
  final String id;
  final String plotlineId;
  final DateTime createdAt;
  final String transcript;
  final String? summary;
  final String? moodKeyword;
  final double moodScore; // -1.0 to 1.0
  final String? emoji;
  final SessionType type;

  Session({
    required this.id,
    required this.plotlineId,
    required this.createdAt,
    required this.transcript,
    this.summary,
    this.moodKeyword,
    this.moodScore = 0.0,
    this.emoji,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plotlineId': plotlineId,
      'createdAt': Timestamp.fromDate(createdAt),
      'transcript': transcript,
      'summary': summary,
      'moodKeyword': moodKeyword,
      'moodScore': moodScore,
      'emoji': emoji,
      'type': type.name,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'] ?? '',
      plotlineId: map['plotlineId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      transcript: map['transcript'] ?? '',
      summary: map['summary'],
      moodKeyword: map['moodKeyword'],
      moodScore: (map['moodScore'] as num?)?.toDouble() ?? 0.0,
      emoji: map['emoji'],
      type: SessionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => SessionType.manual,
      ),
    );
  }
}
