import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  String visitedUserId;
  Timestamp lastMessagetimestamp;
  Timestamp addedUserat;
  String lastMessagetext;
  bool isRead;
  Timestamp lastSeen;

  ChatModel({
    required this.isRead,
    required this.visitedUserId,
    required this.addedUserat,
    required this.lastMessagetimestamp,
    required this.lastMessagetext,
    required this.lastSeen,
  });

  factory ChatModel.fromDoc(DocumentSnapshot doc) {
    return ChatModel(
        isRead: doc["isRead"],
        visitedUserId: doc['visitedUserId'],
        addedUserat: doc['added User at '],
        lastMessagetext: doc['lastMessage text'],
        lastMessagetimestamp: doc['lastMessage Timestamp'],
        lastSeen: doc['lastSeen']);
  }
}
