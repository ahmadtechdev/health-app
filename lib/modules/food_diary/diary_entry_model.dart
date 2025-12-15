import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a diary entry stored in Firestore
class DiaryEntryModel {
  final String id;
  final String productName;
  final double calories;
  final DateTime timestamp;
  final String barcode;
  final Map<String, dynamic>? nutrientInfo;

  DiaryEntryModel({
    required this.id,
    required this.productName,
    required this.calories,
    required this.timestamp,
    required this.barcode,
    this.nutrientInfo,
  });

  factory DiaryEntryModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return DiaryEntryModel(
      id: doc.id,
      productName: data['productName'] as String? ?? 'Unknown item',
      calories: (data['calories'] as num?)?.toDouble() ?? 0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      barcode: data['barcode'] as String? ?? '',
      nutrientInfo: (data['nutrientInfo'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'calories': calories,
      'timestamp': Timestamp.fromDate(timestamp),
      'barcode': barcode,
      'nutrientInfo': nutrientInfo,
    };
  }
}

