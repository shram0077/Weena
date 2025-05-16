import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String id;
  String postuid;
  String userId;
  String title;
  String description;
  List<String> video;
  Timestamp timestamp;
  String type;
  int episode;
  int popularity;
  String thumbnail;
  bool verified;
  List<String> tags;
  int series;
  double imdbRating;
  String trailer;
  int views;
  int likes;

  PostModel({
    required this.postuid,
    required this.series,
    required this.imdbRating,
    required this.userId,
    required this.episode,
    required this.title,
    required this.timestamp,
    required this.description,
    required this.video,
    required this.type,
    required this.popularity,
    required this.id,
    required this.thumbnail,
    required this.verified,
    required this.tags,
    required this.views,
    required this.likes,
    required this.trailer,
  });

  factory PostModel.fromDoc(DocumentSnapshot doc) {
    return PostModel(
      id: doc.id,
      description: doc['description'],
      userId: doc['userId'],
      video: List<String>.from(doc['video'] ?? []),
      timestamp: doc['timestamp'],
      postuid: doc['postuid'],
      title: doc['title'],
      type: doc['type'],
      popularity: doc['popularity'],
      thumbnail: doc['thumbnail'],
      verified: doc['verified'],
      episode: doc['episode'],
      tags: List<String>.from(doc['tags'] ?? []),
      series: doc['series'],
      trailer: doc['trailer'],
      imdbRating: (doc['imdbRating'] ?? 0.0).toDouble(),
      likes: doc['likes'],
      views: doc['views'],
    );
  }
}
