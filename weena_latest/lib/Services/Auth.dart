import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:h_alert_dialog/h_alert_dialog.dart';
import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/encryption_decryption/encryption.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static Future<bool> signUp(
      String name,
      String email,
      String password,
      String gender,
      bool admin,
      String username,
      DateTime birthday,
      ctx) async {
    try {
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User signedInUser = authResult.user!;

      usersRef.doc(signedInUser.uid).set({
        'id': _auth.currentUser!.uid,
        'password': MyEncriptionDecription.encryptWithAESKey(password),
        'name': name,
        'email': MyEncriptionDecription.encryptWithAESKey(email),
        'profilePicture': '',
        'verification': false,
        'bio': '',
        'gender': gender,
        'joinedAt': Timestamp.now(),
        'admin': admin,
        'isAnonymousUser': false,
        'isVerified': false,
        'coverPicture': '',
        'country': '',
        'cityorTown': '',
        'ActiveTime': Timestamp.now(),
        'username': username,
        'birthday': birthday,
        "pushToken": ""
      });
      linksRef
          .doc(_auth.currentUser!.uid)
          .set({'Facebook': "", "Instagram": "", "YouTube": ""});
      return true;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      if (e.toString() ==
          "[firebase_auth/network-request-failed] A network error (such as timeout, interrupted connection or unreachable host) has occurred.") {
        HAlertDialog.showCustomAlertBox(
          context: ctx,
          backgroundColor: moviePageColor,
          title: "کێشەی ئینتەرنێت",
          description: "تکایە پەیوەست ببە بە ئینتەرنێتەوە",
          icon: CupertinoIcons.wifi_exclamationmark,
          iconSize: 32,
          iconColor: moviePageColor,
          titleFontFamily: 'Sirwan',
          titleFontSize: 22,
          titleFontColor: Colors.red,
          descriptionFontFamily: 'Sirwan',
          descriptionFontColor: const Color.fromARGB(153, 0, 0, 0),
          descriptionFontSize: 18.5,
          timerInSeconds: 5,
        );
      }
      return false;
    }
  }

  static Future<bool> login(String email, String password, ctx) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await usersRef.doc(_auth.currentUser!.uid).update(
        {
          'password': MyEncriptionDecription.encryptWithAESKey(password),
          "email": MyEncriptionDecription.encryptWithAESKey(email)
        },
      );
      return true;
    } catch (e) {
      print("this is Error: $e");
      if (e.toString() ==
          "[firebase_auth/network-request-failed] A network error (such as timeout, interrupted connection or unreachable host) has occurred.") {
        HAlertDialog.showCustomAlertBox(
          context: ctx,
          backgroundColor: moviePageColor,
          title: "کێشەی ئینتەرنێت",
          description: "تکایە پەیوەست ببە بە ئینتەرنێتەوە",
          icon: CupertinoIcons.wifi_exclamationmark,
          iconSize: 32,
          iconColor: moviePageColor,
          titleFontFamily: 'Sirwan',
          titleFontSize: 22,
          titleFontColor: Colors.red,
          descriptionFontFamily: 'Sirwan',
          descriptionFontColor: const Color.fromARGB(153, 0, 0, 0),
          descriptionFontSize: 18.5,
          timerInSeconds: 5,
        );
      }
      return false;
    }
  }

  static Future<bool> anonymousSignin() async {
    try {
      await _auth.signInAnonymously();
      return true;
    } catch (e) {
      print(e);
      return true;
    }
  }

  static void logout(context) async {
    try {
      await _auth.signOut();

      // Navigator.pushNamed(
      //   context,
      //   "/welcomescreen",
      // );
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
    }
  }
}
