import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  String commentText;
  String byUserId;
  double rating;
  String postuid;
  Timestamp timestamp;
  bool author;
  CommentModel({
    required this.byUserId,
    required this.rating,
    required this.commentText,
    required this.postuid,
    required this.author,
    required this.timestamp,
  });

  factory CommentModel.fromDoc(DocumentSnapshot doc) {
    return CommentModel(
        timestamp: doc['Timestamp'],
        byUserId: doc['byUserId'],
        commentText: doc['commentText'],
        rating: doc['rating'],
        postuid: doc['postuid'],
        author: doc['author']);
  }
}
