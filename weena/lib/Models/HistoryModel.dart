import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryModel {
  String postuid;
  String ownerId;
  Timestamp timestamp;
  HistoryModel({
    required this.postuid,
    required this.ownerId,
    required this.timestamp,
  });

  factory HistoryModel.fromDoc(DocumentSnapshot doc) {
    return HistoryModel(
        timestamp: doc['Timestamp'],
        postuid: doc['postuid'],
        ownerId: doc["OwnerId"]);
  }
}
