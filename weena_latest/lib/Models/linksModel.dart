import 'package:cloud_firestore/cloud_firestore.dart';

class LinksModel {
  String facebook;
  String youtube;
  String instagram;

  LinksModel({
    required this.instagram,
    required this.youtube,
    required this.facebook,
  });

  factory LinksModel.fromDoc(DocumentSnapshot doc) {
    return LinksModel(
        facebook: doc['Facebook'],
        instagram: doc['Instagram'],
        youtube: doc['YouTube']);
  }
}
