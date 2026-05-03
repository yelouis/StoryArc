import 'package:cloud_firestore/cloud_firestore.dart';

enum SessionType { manual, voice }

class Session {
  final String id;
  final String content;
  final DateTime createdAt;
  final String plotlineId;
  final SessionType type;

  Session({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.plotlineId,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'plotlineId': plotlineId,
      'type': type.name,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      plotlineId: map['plotlineId'] ?? '',
      type: SessionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => SessionType.manual,
      ),
    );
  }
}
