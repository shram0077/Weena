import 'package:cloud_firestore/cloud_firestore.dart';

class UserModell {
  String id;
  String name;
  String profilePicture;
  String coverPicture;
  String email;
  String bio;
  bool verification;
  String gender;
  bool admin;
  bool isVerified;
  Timestamp joinedAt;
  String country;
  String cityorTown;
  Timestamp activeTime;
  String username;
  String pushToken;
  UserModell(
      {required this.id,
      required this.name,
      required this.profilePicture,
      required this.coverPicture,
      required this.email,
      required this.bio,
      required this.verification,
      required this.gender,
      required this.admin,
      required this.joinedAt,
      required this.isVerified,
      required this.country,
      required this.cityorTown,
      required this.activeTime,
      required this.username,
      required this.pushToken});

  factory UserModell.fromDoc(DocumentSnapshot doc) {
    return UserModell(
        id: doc.id,
        name: doc['name'],
        email: doc['email'],
        profilePicture: doc['profilePicture'],
        bio: doc['bio'],
        gender: doc['gender'],
        verification: doc['verification'],
        joinedAt: doc['joinedAt'],
        admin: doc['admin'],
        isVerified: doc['isVerified'],
        coverPicture: doc['coverPicture'],
        cityorTown: doc['cityorTown'],
        country: doc['country'],
        activeTime: doc['ActiveTime'],
        username: doc['username'],
        pushToken: doc["pushToken"]);
  }
}
