import 'package:cloud_firestore/cloud_firestore.dart';

class FeedModel {
  String postuid;
  String ownerId;
  String description;
  int likes;
  int dislikes;
  int refeed;
  List pictures;
  Timestamp timestamp;
  FeedModel({
    required this.postuid,
    required this.description,
    required this.likes,
    required this.refeed,
    required this.pictures,
    required this.ownerId,
    required this.timestamp,
    required this.dislikes,
  });

  factory FeedModel.fromDoc(DocumentSnapshot doc) {
    return FeedModel(
        timestamp: doc['timestamp'],
        postuid: doc['postId'],
        ownerId: doc["ownerId"],
        refeed: doc['refeed'],
        dislikes: doc["dislikes"],
        description: doc["description"],
        likes: doc["likes"],
        pictures: doc["images"]);
  }
}
