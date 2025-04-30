import 'dart:async';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weena_latest/APi/apis.dart';
import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Models/userModel.dart';
import 'package:weena_latest/Screens/History/historyView.dart';
import 'package:weena_latest/Screens/Profile/Settings/BecamePublisher/becamePublisher.dart';
import 'package:weena_latest/Screens/Profile/Settings/Settings.dart';
import 'package:weena_latest/encryption_decryption/encryption.dart';
import '../../Profile/Followers_Following/Followers_Following.dart';
import '../../../Widgets/widget.dart';

class BuildDrawer extends StatefulWidget {
  final String version;
  final int followersCount;
  final int followingCount;

  const BuildDrawer(
      {Key? key,
      required this.version,
      required this.followersCount,
      required this.followingCount})
      : super(key: key);

  @override
  State<BuildDrawer> createState() => _BuildDrawerState();
}

class _BuildDrawerState extends State<BuildDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String admIMG =
      "https://firebasestorage.googleapis.com/v0/b/the-movies-and-drama.appspot.com/o/coverPicture%2FcoverPicture%2Fusers%2FuserCover_O0vj0b7RaYUi2UU4wAZ9ITqmWFE3.jpg?alt=media&token=e2090664-befa-474e-9344-898aa2405e74";
  String onClickLink = "https://www.weena.app";
  void fetchAds() async {
    QuerySnapshot collection =
        await FirebaseFirestore.instance.collection('Ads').get();
    var random = Random().nextInt(collection.docs.length);
    DocumentSnapshot randomDoc = collection.docs[random];
    setState(() {
      admIMG = randomDoc["image"];
      onClickLink = randomDoc["oneClickLink"];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchAds();
    });
    fetchAds();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: const BoxDecoration(color: whiteColor),
      child: StreamBuilder(
          stream: usersRef.doc(_auth.currentUser!.uid).snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircleProgressIndicator());
            } else if (snapshot == ConnectionState.waiting) {
              return Center(child: CircleProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Snapshot Error',
                        style: GoogleFonts.alef(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: errorColor)),
                  ],
                ),
              );
            }
            UserModell userModel = UserModell.fromDoc(snapshot.data);
            return ListView(
              children: [
                UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                        image: userModel.coverPicture.isEmpty
                            ? DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage("assets/images/weena.png"))
                            : DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(
                                    MyEncriptionDecription.decryptWithAESKey(
                                        userModel.coverPicture)))),
                    currentAccountPicture: userModel.coverPicture.isEmpty
                        ? const SizedBox()
                        : Container(
                            padding: const EdgeInsets.all(1),
                            height: 12,
                            width: 12,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(255, 78, 89, 123)
                                      .withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 2,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl:
                                    MyEncriptionDecription.decryptWithAESKey(
                                        userModel.profilePicture),
                                fit: BoxFit.cover,
                                width: 12,
                                height: 12,
                              ),
                            ),
                          ),
                    accountName: userModel.coverPicture.isEmpty
                        ? SizedBox()
                        : Flexible(
                            child: Row(
                              children: [
                                Text(
                                  userModel.name,
                                  style: GoogleFonts.barlow(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                userModel.verification
                                    ? verfiedBadge(22, 22)
                                    : const SizedBox(),
                                userModel.admin
                                    ? adminBadge(25, 25)
                                    : SizedBox()
                              ],
                            ),
                          ),
                    accountEmail: const SizedBox()),
                GestureDetector(
                  onTap: () {
                    var key;
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.topToBottom,
                            child: ViewFollowersandFollowing(
                              currentUserId: APi.myid,
                              visitedUserId: userModel.id,
                              key: key,
                            )));
                  },
                  child: Flexible(
                      child: Container(
                    padding: const EdgeInsets.all(4),
                    color: whiteColor.withOpacity(0.6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        text("Followers ${widget.followersCount}", appBarColor,
                            14, FontWeight.w600, TextDirection.rtl),
                        Container(
                          height: 11,
                          width: 1.5,
                          color: Colors.grey[500],
                        ),
                        text("Following ${widget.followingCount}", appBarColor,
                            14, FontWeight.w600, TextDirection.rtl)
                      ],
                    ),
                  )),
                ),
                const Divider(
                  color: Colors.grey,
                  endIndent: 7,
                  indent: 7,
                  thickness: 0.2,
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: SettingScreen(
                              currentUserId: _auth.currentUser!.uid,
                              userModel: userModel,
                              visitedUserId: userModel.id,
                            )));
                  },
                  title: text("Setting".tr, appBarColor, 15, FontWeight.normal,
                      TextDirection.rtl),
                  leading: const Icon(
                    CupertinoIcons.settings,
                    color: appBarColor,
                  ),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: HistoryView(
                              currentUserId: _auth.currentUser!.uid,
                            )));
                  },
                  title: text("بینراوەکان", appBarColor, 15, FontWeight.normal,
                      TextDirection.rtl),
                  leading: const Icon(
                    CupertinoIcons.play_circle,
                    color: appBarColor,
                  ),
                ),
                userModel.isVerified && userModel.verification
                    ? SizedBox()
                    : ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: BecamePublisher(
                                    currentUserId: userModel.id,
                                    userModell: userModel,
                                  )));
                        },
                        title: text("بوون بەبڵاوکەر", appBarColor, 15,
                            FontWeight.normal, TextDirection.rtl),
                        leading: const Icon(
                          CupertinoIcons.upload_circle,
                          color: appBarColor,
                        ),
                      ),
                const Divider(
                  color: Colors.grey,
                  endIndent: 7,
                  indent: 7,
                  thickness: 0.2,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      text("ئێمە".tr, Colors.grey, 18, FontWeight.normal,
                          TextDirection.rtl),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 3, right: 3),
                          child: GestureDetector(
                            onTap: () async {
                              var url =
                                  "https://www.facebook.com/weena.app.official";
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                print('Could not launch $url');
                              }
                            },
                            child: socialMediaButton(
                                Colors.blue, FontAwesome.facebook),
                          )),
                      Padding(
                          padding: const EdgeInsets.only(left: 3, right: 3),
                          child: GestureDetector(
                            onTap: () async {
                              var url = "https://www.instagram.com/weena.app/";
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                print('Could not launch $url');
                              }
                            },
                            child: socialMediaButton(
                                const Color.fromARGB(255, 244, 45, 111),
                                FontAwesome.instagram),
                          )),
                      Padding(
                          padding: const EdgeInsets.only(left: 3, right: 3),
                          child: GestureDetector(
                            onTap: () async {
                              var url = "https://twitter.com/weenaapp";
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                print('Could not launch $url');
                              }
                            },
                            child: socialMediaButton(
                                Colors.blue, FontAwesome.twitter),
                          ))
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  color: whiteColor,
                  endIndent: 7,
                  indent: 7,
                  thickness: 0.2,
                ),
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: text("وەشان: ${widget.version}", whiteColor, 16,
                      FontWeight.w400, TextDirection.ltr),
                ),
                const SizedBox(
                  height: 30,
                ),
                admIMG != null ? buildAds(admIMG, onClickLink) : SizedBox()
              ],
            );
          }),
    );
  }
}
