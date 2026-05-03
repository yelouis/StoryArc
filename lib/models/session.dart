import 'package:cloud_firestore/cloud_firestore.dart';

enum SessionType { manual, voice }

class Session {
  final String id;
  final String plotlineId;
  final DateTime createdAt;
  final String transcript;
  final String? title;
  final String? summary;
  final String? moodKeyword;
  final double moodScore; // -1.0 to 1.0
  final List<String> emojis;
  final SessionType type;

  Session({
    required this.id,
    required this.plotlineId,
    required this.createdAt,
    required this.transcript,
    this.title,
    this.summary,
    this.moodKeyword,
    this.moodScore = 0.0,
    this.emojis = const [],
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plotlineId': plotlineId,
      'createdAt': Timestamp.fromDate(createdAt),
      'transcript': transcript,
      'title': title,
      'summary': summary,
      'moodKeyword': moodKeyword,
      'moodScore': moodScore,
      'emojis': emojis,
      'type': type.name,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'] ?? '',
      plotlineId: map['plotlineId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      transcript: map['transcript'] ?? '',
      title: map['title'],
      summary: map['summary'],
      moodKeyword: map['moodKeyword'],
      moodScore: (map['moodScore'] as num?)?.toDouble() ?? 0.0,
      emojis: List<String>.from(map['emojis'] ?? []),
      type: SessionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => SessionType.manual,
      ),
    );
  }
}
