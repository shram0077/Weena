import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:weena/Constant/constant.dart';
import 'package:weena/Models/ActivityModel.dart';
import 'package:weena/Models/userModel.dart';
import 'package:weena/Screens/Profile/profile.dart';
import 'package:weena/Screens/Search/search.dart';
import 'package:weena/Screens/Welcome/welcome.dart';
import 'package:weena/Widgets/widget.dart';
import 'package:weena/encryption_decryption/encryption.dart';

class SearchBarr extends StatefulWidget {
  final String currentUserId;
  final String? visitedUserId;
  final UserModell? userModel;
  final ActivityModel? activityModel;
  final bool user;
  const SearchBarr(
      {key,
      required this.currentUserId,
      this.visitedUserId,
      this.userModel,
      this.activityModel,
      required this.user})
      : super(key: key);
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
      Timer.periodic(const Duration(seconds: 55), (timer) async {
        await usersRef
            .doc(widget.currentUserId)
            .update({"ActiveTime": Timestamp.now()});
      });
    } else {
      print("Go Offline");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: widget.user
          ? GestureDetector(
              onTap: () async {
                var url = "https://www.facebook.com/weenakrd";
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  print('Could not launch $url');
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 6, bottom: 6),
                child: Lottie.asset(
                  'assets/animations/ActionAnim.json',
                  height: 25,
                  width: 25,
                ),
              ),
            )
          : IconButton(
              icon: const Icon(
                Icons.menu,
                color: Color(0xFF545454),
              ),
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
                  )));
        },
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(15)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                CupertinoIcons.search,
                color: Color(0xFF545454),
              ),
              text("Search Movies,Dramas,Users", const Color(0xFF545454), 14,
                  FontWeight.w400, TextDirection.rtl),
            ],
          ),
        ),
      ),
      backgroundColor: whiteColor,
      elevation: 0,
      actions: [
        widget.user
            ?
            // If user is Anonymous
            GestureDetector(
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
                          )));
                },
                child: const Padding(
                    padding: EdgeInsets.all(5.0),
                    child: CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 228, 221, 221),
                      backgroundImage: AssetImage('assets/images/person.png'),
                    )),
              )
            : StreamBuilder(
                stream: usersRef.doc(widget.currentUserId).snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: loadingProfileContiner());
                  } else if (snapshot == ConnectionState.waiting) {
                    return Center(child: loadingProfileContiner());
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
                              )));
                    },
                    child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Container(
                          padding: const EdgeInsets.all(1.5),
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 228, 221, 221),
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
                            child: CachedNetworkImage(
                              imageUrl:
                                  MyEncriptionDecription.decryptWithAESKey(
                                      userModel.profilePicture),
                              fit: BoxFit.cover,
                              width: 45,
                              height: 45,
                            ),
                          ),
                        )),
                  );
                }),
      ],
      automaticallyImplyLeading: false,
    );
  }
}
