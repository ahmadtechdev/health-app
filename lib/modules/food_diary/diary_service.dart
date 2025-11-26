import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'diary_entry_model.dart';

class DiaryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns formatted date key (yyyy-MM-dd)
  String dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  /// Collection reference for user's diary entries on specific date
  CollectionReference<Map<String, dynamic>> _entriesRef(
    String userId,
    String dateKey,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('diary')
        .doc(dateKey)
        .collection('entries');
  }

  Future<void> addEntry({
    required String userId,
    required DiaryEntryModel entry,
  }) async {
    final key = dateKey(entry.timestamp);
    await _entriesRef(userId, key).add(entry.toMap());
  }

  Stream<List<DiaryEntryModel>> watchEntries({
    required String userId,
    required DateTime date,
  }) {
    final key = dateKey(date);
    return _entriesRef(userId, key)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DiaryEntryModel.fromDoc(doc)).toList());
  }

  Future<double?> fetchTargetCalories(String userId) async {
    final profileDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('profile')
        .doc('data')
        .get();

    if (!profileDoc.exists) return null;
    final data = profileDoc.data();
    if (data == null) return null;
    return (data['goalCalories'] as num?)?.toDouble();
  }
}

