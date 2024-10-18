// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';

class SeriesModel {
  String id;
  Timestamp timestamp;
  int episode;
  String thumbnail;
  String videoLink;
  SeriesModel({
    required this.id,
    required this.episode,
    required this.timestamp,
    required this.videoLink,
    required this.thumbnail,
  });

  factory SeriesModel.fromDoc(DocumentSnapshot doc) {
    return SeriesModel(
        id: doc.id,
        timestamp: doc['Timestamp'],
        videoLink: doc['video'],
        episode: doc['episode'],
        thumbnail: doc['thumbnail']);
  }
}
