import 'package:cloud_firestore/cloud_firestore.dart';

class Session {
  final String id;
  final String plotlineId;
  final DateTime date;
  final String transcript;
  final String? summary;
  final String? moodKeyword;
  final double moodScore; // -1.0 to 1.0
  final String? emoji; // Visual anchor for the session

  Session({
    required this.id,
    required this.plotlineId,
    required this.date,
    required this.transcript,
    this.summary,
    this.moodKeyword,
    required this.moodScore,
    this.emoji,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plotlineId': plotlineId,
      'date': Timestamp.fromDate(date),
      'transcript': transcript,
      'summary': summary,
      'moodKeyword': moodKeyword,
      'moodScore': moodScore,
      'emoji': emoji,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'] ?? '',
      plotlineId: map['plotlineId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      transcript: map['transcript'] ?? '',
      summary: map['summary'],
      moodKeyword: map['moodKeyword'],
      moodScore: (map['moodScore'] as num?)?.toDouble() ?? 0.0,
      emoji: map['emoji'],
    );
  }
}
