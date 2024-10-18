import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  String id;
  Timestamp timestamp;
  String activityType;
  String activityMessage;
  String byUserId;
  String thumbnail;
  ActivityModel({
    required this.id,
    required this.timestamp,
    required this.byUserId,
    required this.activityType,
    required this.activityMessage,
    required this.thumbnail,
  });

  factory ActivityModel.fromDoc(DocumentSnapshot doc) {
    return ActivityModel(
        id: doc.id,
        timestamp: doc['Timestamp'],
        byUserId: doc['byUserId'],
        activityType: doc['ActivityType'],
        activityMessage: doc['activityMessage'],
        thumbnail: doc['thumbnail']);
  }
}
