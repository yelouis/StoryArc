import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/plotline.dart';
import '../onboarding/auth_service.dart';

final plotlineRepositoryProvider = Provider<PlotlineRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return PlotlineRepository(authService);
});

class PlotlineRepository {
  final AuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PlotlineRepository(this._authService);

  CollectionReference get _plotlinesCollection {
    final uid = _authService.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(uid).collection('plotlines');
  }

  Stream<List<Plotline>> getPlotlines() {
    return _plotlinesCollection
        .orderBy('lastActive', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Plotline.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> addPlotline(Plotline plotline) async {
    await _plotlinesCollection.doc(plotline.id).set(plotline.toMap());
  }

  Future<void> updatePlotline(Plotline plotline) async {
    await _plotlinesCollection.doc(plotline.id).update(plotline.toMap());
  }

  Future<void> deletePlotline(String id) async {
    await _plotlinesCollection.doc(id).delete();
  }

  Future<void> togglePin(String plotlineId, bool isPinned) async {
    await _plotlinesCollection.doc(plotlineId).update({'isPinned': isPinned});
  }
}
