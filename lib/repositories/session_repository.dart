import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/session.dart';
import '../onboarding/auth_service.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return SessionRepository(authService);
});

class SessionRepository {
  final AuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SessionRepository(this._authService);

  CollectionReference _sessionsCollection(String plotlineId) {
    final uid = _authService.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('plotlines')
        .doc(plotlineId)
        .collection('sessions');
  }

  Stream<List<Session>> getSessions(String plotlineId) {
    return _sessionsCollection(plotlineId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Session.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> addSession(Session session) async {
    await _sessionsCollection(session.plotlineId).doc(session.id).set(session.toMap());
    
    // Update the lastActive timestamp on the plotline
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('plotlines')
          .doc(session.plotlineId)
          .update({'lastActive': Timestamp.fromDate(session.createdAt)});
    }
  }

  Future<void> deleteSession(String plotlineId, String sessionId) async {
    await _sessionsCollection(plotlineId).doc(sessionId).delete();
  }
}
