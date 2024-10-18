import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:http/http.dart';
import 'dart:convert';

import 'package:weena/Constant/constant.dart';
import 'package:weena/Models/userModel.dart';

class APi {
  static dynamic me;
  static dynamic vistitedUser;
  static final myid = FirebaseAuth.instance.currentUser!.uid;
  static Future<void> getSelfInfo() async {
    await usersRef.doc(myid).get().then((user) async {
      if (user.exists) {
        me = UserModell.fromDoc(user);
      } else {}
    });
  }

  static Future<void> getUserInfo(String userid) async {
    await usersRef.doc(userid).get().then((user) async {
      if (user.exists) {
        vistitedUser = UserModell.fromDoc(user);
        print(vistitedUser.name);
      } else {}
    });
  }

  static Future<void> sendMessagePushNotification(
      String msg, String pushToken) async {
    try {
      final body = {
        "to": pushToken,
        "notification": {
          "title": APi.me.username, //our name should be send
          "body": msg,
        },
      };
// Send push Notifaction
      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAu0NNe64:APA91bFF60EQJxwQIGq_zd74ovnAUSvL0GK0DTystljOraATRaExr4oqWse-h0S04moibFwldF_Qd2xII4XmX0HR6n2KouXXQISRyYEvR_Ce8Q3ruwI_mfSaqopXhSwRVAc9Dx1hudPI'
          },
          body: jsonEncode(body));
      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');
    } catch (e) {
      print('\nsendPushNotificationE: $e');
    }
  }

  static Future<void> sendAddedPushNotification(String pushToken) async {
    try {
      final body = {
        "to": pushToken,
        "notification": {
          "title": "${APi.me.username} زیادی کردیت ", //our name should be send
        },
      };
// Send push Notifaction
      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAu0NNe64:APA91bFF60EQJxwQIGq_zd74ovnAUSvL0GK0DTystljOraATRaExr4oqWse-h0S04moibFwldF_Qd2xII4XmX0HR6n2KouXXQISRyYEvR_Ce8Q3ruwI_mfSaqopXhSwRVAc9Dx1hudPI'
          },
          body: jsonEncode(body));
      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');
    } catch (e) {
      print('\nsendPushNotificationE: $e');
    }
  }

  static Future<void> sendFollowPushNotification(String pushToken) async {
    try {
      final body = {
        "to": pushToken,
        "notification": {
          "title": "${APi.me.username} دوای تۆ کەوت", //our name should be send
        },
      };
// Send push Notifaction
      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAu0NNe64:APA91bFF60EQJxwQIGq_zd74ovnAUSvL0GK0DTystljOraATRaExr4oqWse-h0S04moibFwldF_Qd2xII4XmX0HR6n2KouXXQISRyYEvR_Ce8Q3ruwI_mfSaqopXhSwRVAc9Dx1hudPI'
          },
          body: jsonEncode(body));
      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');
    } catch (e) {
      print('\nsendPushNotificationE: $e');
    }
  }
}
