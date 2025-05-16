import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Models/ActivityModel.dart';
import 'package:weena_latest/Models/userModel.dart';
import 'package:weena_latest/Screens/Profile/profile.dart';
import 'package:weena_latest/Screens/Search/search.dart';
import 'package:weena_latest/Screens/Welcome/welcome.dart';
import 'package:weena_latest/Widgets/widget.dart';
import 'package:weena_latest/encryption_decryption/encryption.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class SearchBarr extends StatefulWidget {
  final String currentUserId;
  final String? visitedUserId;
  final UserModell? userModel;
  final ActivityModel? activityModel;
  final bool user;
  const SearchBarr({
    key,
    required this.currentUserId,
    this.visitedUserId,
    this.userModel,
    this.activityModel,
    required this.user,
  }) : super(key: key);
  @override
  State<SearchBarr> createState() => _SearchBarrState();
}

class _SearchBarrState extends State<SearchBarr> with WidgetsBindingObserver {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    usersRef.doc(widget.currentUserId).update({"ActiveTime": Timestamp.now()});
    WidgetsBinding.instance.addObserver(this);
    didChangeAppLifecycleState(AppLifecycleState.resumed);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Timer.periodic(Duration(seconds: 55), (timer) async {
        await usersRef.doc(widget.currentUserId).update({
          "ActiveTime": Timestamp.now(),
        });
      });
    } else {
      print("Go Offline");
    }
  }
@override
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double screenWidth = constraints.maxWidth;

      return AppBar(
        leading: widget.user
            ? GestureDetector(
                onTap: () async {
                  var url = "https://www.facebook.com/weenakrd";
                  if (await canLaunch(url)) {
                    await launch(url);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 6, bottom: 6),
                  child: Lottie.asset(
                    'assets/animations/ActionAnim.json',
                    height: screenWidth * 0.06,
                    width: screenWidth * 0.06,
                  ),
                ),
              )
            : IconButton(
                icon: Icon(Icons.menu, color: Color(0xFF545454)),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: SearchSC(
                  fromDashdboard: true,
                  currentUserId: widget.currentUserId,
                  fromDashdboardTags: "",
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.025,
              vertical: screenWidth * 0.015,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.search, color: Color(0xFF545454)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    "Search Movies,Dramas,Users".tr,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.barlow(
                      fontSize: screenWidth * 0.047,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF545454),
                      
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: whiteColor,
        elevation: 0,
        actions: [
          widget.user
              ? GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.topToBottom,
                        child: WelcomeScreen(
                          isSkiped: true,
                          activityModel: widget.activityModel,
                          currentUserId: widget.currentUserId,
                          userModell: widget.userModel,
                          visitedUserId: widget.visitedUserId,
                        ),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(5.0),
                    child: CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 228, 221, 221),
                      backgroundImage: AssetImage('assets/images/person.png'),
                    ),
                  ),
                )
              : StreamBuilder(
                  stream: usersRef.doc(widget.currentUserId).snapshots(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) return loadingProfileContiner();
                    if (snapshot.hasError) return Text("Error loading profile");
                    UserModell userModel = UserModell.fromDoc(snapshot.data);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.topToBottom,
                            child: ProfileScreen(
                              currentUserId: widget.currentUserId,
                              userModel: userModel,
                              visitedUserId: userModel.id,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Container(
                          height: screenWidth * 0.12,
                          width: screenWidth * 0.12,
                          padding: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            color: userModel.profilePicture.isEmpty
                                ? Colors.white
                                : const Color.fromARGB(255, 228, 221, 221),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 78, 89, 123)
                                    .withOpacity(0.1),
                                spreadRadius: 0.2,
                                blurRadius: 0.2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: userModel.profilePicture.isEmpty
                                ? Image.asset(
                                    "assets/images/person.png",
                                    fit: BoxFit.contain,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: MyEncriptionDecription
                                        .decryptWithAESKey(
                                            userModel.profilePicture),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
        automaticallyImplyLeading: false,
      );
    },
  );
}}