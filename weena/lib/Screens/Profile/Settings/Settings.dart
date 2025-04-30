// ignore: file_names
import 'dart:async';
import 'dart:math';

import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:weena/Constant/constant.dart';
import 'package:weena/Models/userModel.dart';
import 'package:weena/Screens/Profile/Settings/BecamePublisher/becamePublisher.dart';
import 'package:weena/Screens/Profile/Settings/Blocked/blockedUsers.dart';
import 'package:weena/Screens/Profile/Settings/Edit_locations.dart';
import 'package:weena/Screens/Profile/Settings/EditeProfile.dart';
import 'package:weena/Screens/Profile/Settings/ForgetPassword.dart';
import 'package:weena/Screens/Profile/Settings/Links.dart';
import 'package:weena/Widgets/widget.dart';
import 'package:weena/encryption_decryption/encryption.dart';

class SettingScreen extends StatefulWidget {
  final String currentUserId;
  final String visitedUserId;
  final UserModell userModel;

  const SettingScreen(
      {super.key,
      required this.currentUserId,
      required this.visitedUserId,
      required this.userModel});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _auth = FirebaseAuth.instance;
  bool? _isUserEmailVerified;
  checkEmail() async {
    await FirebaseAuth.instance.currentUser!.reload();
    if (_auth.currentUser!.emailVerified) {
      setState(() {
        _isUserEmailVerified == _auth.currentUser!.emailVerified;
      });
    }
  }

  var key;

  String admIMG = "https://weena.app/wp-content/uploads/2023/06/Weena-3-05.png";
  String onClickLink = "https://weena.app";
  fetchAds() async {
    // first get a snapshot of your collection
    QuerySnapshot collection =
        await FirebaseFirestore.instance.collection('Ads').get();

// based on how many documents you have in your collection
// just pull one random index
    var random = Random().nextInt(collection.docs.length);

// then just get the document that falls under that random index
    DocumentSnapshot randomDoc = collection.docs[random];
    print("Ads: ${randomDoc["image"]}");
    setState(() {
      admIMG = randomDoc["image"];
      onClickLink = randomDoc["oneClickLink"];
    });
  }

  var privacyPolicyUri = "";
  void fetchPrivacyPolicy() async {
    QuerySnapshot collection =
        await FirebaseFirestore.instance.collection('PrivacyPolicy').get();
    var random = Random().nextInt(collection.docs.length);
    DocumentSnapshot randomDoc = collection.docs[random];
    setState(() {
      privacyPolicyUri = randomDoc["uri"];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchPrivacyPolicy();
    fetchAds();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchAds();
    });
    _isUserEmailVerified = _auth.currentUser!.emailVerified;
    checkEmail();
  }

  final List locale = [
    {"name": 'ENGLISH', 'locale': const Locale('en', 'US'), "icon": "🇺🇸 "},
    {
      "name": 'CENTRAL KURDISH',
      'locale': const Locale('krd', 'IQ'),
      'icon': '🇮🇶 '
    },
  ];
  updateLanguage(Locale locale) {
    Get.back();
    Get.updateLocale(locale);
  }

  buildDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (builder) {
          return AlertDialog(
            title: const Text('Choose a language'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                          onTap: () {
                            updateLanguage(locale[index]['locale']);
                            print(locale[index]['name']);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(locale[index]['name']),
                              Text(locale[index]['icon']),
                            ],
                          )),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider(
                      color: appcolor,
                      thickness: 1.5,
                    );
                  },
                  itemCount: locale.length),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Container(
        padding: const EdgeInsets.only(left: 16, top: 25, right: 16),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: appBarColor,
                  ),
                  color: appBarColor,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                text("Setting", appBarColor, 21, FontWeight.w600,
                    TextDirection.rtl),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                normalAvatar(widget.userModel, context, widget.currentUserId,
                    widget.visitedUserId, key, 48, 50, 7),
                const SizedBox(
                  width: 8,
                ),
                text("Profile", appBarColor, 17, FontWeight.w500,
                    TextDirection.rtl),
              ],
            ),
            Divider(
              height: 15,
              thickness: 0.5,
              color: Colors.grey[400],
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: EditeProfile(
                          currentUserId: widget.currentUserId,
                          visitedUserId: widget.visitedUserId,
                          userModel: widget.userModel,
                          key: key,
                        )));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text("Your Profile", appBarColor, 15, FontWeight.normal,
                        TextDirection.rtl),
                    const Icon(
                      Icons.location_history,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: EditLocation(
                          userModell: widget.userModel,
                          key: key,
                        )));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text("Location", appBarColor, 15, FontWeight.normal,
                        TextDirection.rtl),
                    const Icon(
                      Icons.location_city,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: Links(
                          currentUserId: widget.currentUserId,
                        )));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text("Links", appBarColor, 15, FontWeight.normal,
                        TextDirection.rtl),
                    const Icon(
                      Icons.link,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            widget.userModel.isVerified && widget.userModel.verification
                ? const SizedBox()
                : InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: BecamePublisher(
                                currentUserId: widget.currentUserId,
                                userModell: widget.userModel,
                              )));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          text("بوون بە بڵاوکەر", appBarColor, 15,
                              FontWeight.normal, TextDirection.rtl),
                          const Icon(
                            CupertinoIcons.upload_circle,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.privacy_tip_outlined,
                  color: whiteColor,
                ),
                const SizedBox(
                  width: 8,
                ),
                text("Privacy", appBarColor, 17, FontWeight.w500,
                    TextDirection.rtl),
              ],
            ),
            Divider(
              height: 15,
              thickness: 0.5,
              color: Colors.grey[400],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text(
                          'ئیمەیڵ: ${MyEncriptionDecription.decryptWithAESKey(widget.userModel.email)}',
                          _isUserEmailVerified! ? appBarColor : errorColor,
                          15,
                          _isUserEmailVerified!
                              ? FontWeight.w500
                              : FontWeight.bold,
                          TextDirection.ltr),
                    ],
                  ),
                ),
                _isUserEmailVerified!
                    ? const SizedBox()
                    : InkWell(
                        onTap: () {
                          if (_isUserEmailVerified!) {
                            // TODO: implement your code after email verification
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                              "Your email has been successfully verified".tr,
                            )));
                          } else {
                            try {
                              FirebaseAuth.instance.currentUser
                                  ?.sendEmailVerification();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("ئیمەیڵەکەت بپشکنە".tr)));
                            } catch (e) {
                              Fluttertoast.showToast(msg: '$e');
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: text("Verify", whiteColor, 13,
                              FontWeight.normal, TextDirection.rtl),
                        ),
                      ),
              ],
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: ForgetPasswordScreen(
                          key: key,
                        )));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text("Password", appBarColor, 15, FontWeight.w500,
                        TextDirection.rtl),
                    const Icon(
                      Icons.password,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                if (_isUserEmailVerified != true) {
                  Fluttertoast.showToast(msg: 'ئیمەیلەکەت پشتڕاست بکەوە');
                } else {}
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text("جزدان", appBarColor, 15, FontWeight.w500,
                        TextDirection.rtl),
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: BlockedUsers(
                          currentUserId: widget.currentUserId,
                          key: key,
                        )));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text("Blocked", appBarColor, 15, FontWeight.w500,
                        TextDirection.rtl),
                    const Icon(
                      Icons.block_flipped,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                FlutterClipboard.copy(widget.userModel.id);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text(widget.userModel.id, appBarColor, 15, FontWeight.w500,
                        TextDirection.ltr),
                    const Icon(
                      Icons.copy,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Divider(
              height: 15,
              thickness: 0.5,
              color: Colors.grey[400],
            ),
            Center(
              child: MaterialButton(
                color: moviePageColor.withOpacity(0.9),
                padding: const EdgeInsets.symmetric(horizontal: 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: () {
                  logoutDialog();
                },
                child: text("LogOut", whiteColor, 15, FontWeight.w500,
                    TextDirection.rtl),
              ),
            ),
            CupertinoButton(
                child: Text(
                  'سیاسەتی بەکارهێنان',
                  style: GoogleFonts.barlow(
                      fontSize: 15, color: whiteColor.withOpacity(0.8)),
                ),
                onPressed: () async {
                  var url = privacyPolicyUri;
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    print('Could not launch $url');
                  }
                }),
            const SizedBox(
              height: 10,
            ),
            admIMG != null ? buildAds(admIMG, onClickLink) : const SizedBox()
          ],
        ),
      ),
    );
  }

  void logoutDialog() {
    showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              backgroundColor: const Color.fromARGB(255, 234, 230, 230),
              title: Center(
                child: Text(
                  "دڵنیای لە چوونەرەوەی ئەم هەژمارە؟",
                  style: GoogleFonts.barlow(color: appBarColor),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  // ignore: sort_child_properties_last
                  child: Text(
                    'CANCEL'.tr,
                    style: GoogleFonts.barlow(color: appBarColor),
                  ),
                  onPressed: Navigator.of(context).pop,
                ),
                TextButton(
                  child: Text(
                    'بەڵێ',
                    style: GoogleFonts.barlow(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    await _auth.signOut();
                    Navigator.pushNamed(context, "/welcomescreen",
                        arguments: {});
                  },
                )
              ],
            )));
  }
}
