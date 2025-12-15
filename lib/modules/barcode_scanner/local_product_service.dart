import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'nutrition_model.dart';

/// Handles read/write of admin-curated products stored in Firestore.
class LocalProductService {
  static const String collectionName = 'admin_products';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(collectionName);

  /// Fetch a product saved by admins using its barcode.
  Future<NutritionModel?> getByBarcode(String barcode) async {
    if (barcode.isEmpty) return null;
    try {
      final doc = await _collection.doc(barcode).get();
      if (!doc.exists || doc.data() == null) return null;
      final data = doc.data()!;
      return NutritionModel.fromSimpleJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Search a product saved by admins using a name fragment.
  /// The lookup is case-insensitive and matches any keyword.
  Future<NutritionModel?> getByName(String productName) async {
    final normalized = productName.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    try {
      final query = await _collection
          .where('searchKeywords', arrayContains: normalized)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return NutritionModel.fromSimpleJson(query.docs.first.data());
    } catch (_) {
      return null;
    }
  }

  /// Save or update an admin product entry.
  /// Uses the barcode as the document id to keep lookups simple.
  Future<void> saveProduct(NutritionModel model) async {
    final barcode = model.barcode;
    if (barcode == null || barcode.isEmpty) {
      throw ArgumentError('Barcode is required to save a product');
    }

    final now = FieldValue.serverTimestamp();
    final keywords = _buildKeywords(model.productName, model.brand);
    final user = _auth.currentUser;
    final docRef = _collection.doc(barcode);
    final existing = await docRef.get();
    final existingCreatedAt = existing.data()?['createdAt'];

    final payload = {
      ...model.toJson(),
      'searchKeywords': keywords,
      'titleLower': model.productName.toLowerCase(),
      'source': 'admin',
      'updatedAt': now,
      'createdAt': existingCreatedAt ?? now,
      'createdBy': user?.uid,
      'createdByEmail': user?.email,
    };

    await docRef.set(payload, SetOptions(merge: true));
  }

  List<String> _buildKeywords(String name, String? brand) {
    final keywords = <String>{};
    final raw = '$name ${brand ?? ''}'.toLowerCase();
    keywords.add(raw.trim());
    keywords.addAll(
      raw
          .split(RegExp(r'\s+'))
          .where((e) => e.trim().isNotEmpty)
          .map((e) => e.trim()),
    );
    return keywords.toList();
  }
}

