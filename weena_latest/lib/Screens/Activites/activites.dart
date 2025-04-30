// ignore_for_file: dead_code, avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Models/ActivityModel.dart';
import 'package:weena_latest/Models/userModel.dart';
import 'package:weena_latest/Screens/Activites/Activites_Widgets.dart';
import 'package:weena_latest/Screens/Profile/profile.dart';
import 'package:weena_latest/Screens/Welcome/welcome.dart';
import 'package:weena_latest/Services/DatabaseServices.dart';
import 'package:weena_latest/Widgets/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

class ActivitesScreen extends StatefulWidget {
  final String? currentUserId;
  final String? visitedUserId;
  final UserModell? userModell;
  final ActivityModel? activityModel;
  const ActivitesScreen({
    Key? key,
    this.currentUserId,
    this.visitedUserId,
    this.userModell,
    this.activityModel,
  }) : super(key: key);

  @override
  State<ActivitesScreen> createState() => _ActivitesScreenState();
}

class _ActivitesScreenState extends State<ActivitesScreen> {
  List<ActivityModel> _activities = [];

  bool isloadingData = true;
  bool user = FirebaseAuth.instance.currentUser!.isAnonymous;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String activityUuid = const Uuid().v4();
  setupActivities() async {
    List<ActivityModel> activities =
        await DatabaseServices.getActivities(_auth.currentUser!.uid);
    if (mounted) {
      setState(() {
        _activities = activities.toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (user) {
      print('Guest');
    } else {
      setupActivities();
    }
  }

  buildActivity(ActivityModel activityModel) {
    return StreamBuilder(
        stream: usersRef.doc(activityModel.byUserId).snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Padding(
                padding: const EdgeInsets.all(8), child: listcacheUI());
          } else {
            UserModell user = UserModell.fromDoc(snapshot.data);
            return Column(children: [
              !isloadingData
                  ? listcacheUI()
                  : Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 1),
                      child: ListTile(
                        tileColor: Color.fromARGB(255, 251, 250, 250),
                        leading: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.topToBottom,
                                    child: ProfileScreen(
                                      currentUserId: _auth.currentUser!.uid,
                                      userModel: user,
                                      visitedUserId: activityModel.byUserId,
                                    )));
                          },
                          child: buildProfilePicture(user),
                        ),
                        title: buildTitle(activityModel, user.username),
                        trailing: buildTrailing(
                          activityModel,
                          _auth.currentUser!.uid,
                        ),
                        subtitle: Text(
                          timeago.format(
                            activityModel.timestamp.toDate(),
                          ),
                          style: GoogleFonts.barlow(
                              color: Colors.black87,
                              fontSize: 10.5,
                              letterSpacing: 0.7,
                              fontWeight: FontWeight.w600),
                        ),
                      )),
              const Divider(
                color: Colors.grey,
                height: 0.1,
                indent: 0.1,
                endIndent: 0.1,
                thickness: 0.1,
              )
            ]);
          }
        });
  }

  buildTrailing(
    ActivityModel activityModel,
    String currentUserId,
  ) {
    if (activityModel.activityType == 'following') {
    } else if (activityModel.activityType == 'liked post') {
      return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: activityModel.thumbnail.isEmpty
              ? Colors.transparent
              : profileBGcolor,
          borderRadius: BorderRadius.circular(7),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 121, 54, 49).withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: activityModel.thumbnail.isEmpty
            ? SizedBox()
            : ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: activityModel.thumbnail,
                  fit: BoxFit.cover,
                  width: 65,
                ),
              ),
      );
    }
  }

  ActivityModel? activityModel;
  UserModell? userModell;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: text("Activity's".tr, appBarColor, 21, FontWeight.normal,
            TextDirection.rtl),
        backgroundColor: whiteColor,
        elevation: 0.5,
      ),
      body: user
          ? Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10.0, top: 6, bottom: 6),
                    child: Lottie.asset(
                      'assets/animations/Animation-Activites.json',
                      height: 200,
                      width: double.infinity,
                    ),
                  ),
                  text('Activities will appear here'.tr, Colors.black, 20,
                      FontWeight.normal, TextDirection.rtl),
                  const SizedBox(
                    height: 25,
                  ),
                  MaterialButton(
                    minWidth: 300,
                    height: 50,
                    onPressed: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: WelcomeScreen(
                                isSkiped: true,
                                userModell: widget.userModell,
                                activityModel: widget.activityModel,
                                currentUserId: widget.currentUserId,
                                visitedUserId: widget.visitedUserId,
                              )));
                    },
                    color: moviePageColor.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: text("Signup or Sign In".tr, whiteColor, 18,
                        FontWeight.normal, TextDirection.rtl),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => setupActivities(),
              // ignore: sized_box_for_whitespace
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  child: _activities.isEmpty
                      ? Center(
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.cube_box,
                              size: 45,
                              color: whiteColor.withOpacity(0.9),
                            ),
                            text(
                                'There is no any Activity yet.'.tr,
                                Colors.black,
                                23,
                                FontWeight.normal,
                                TextDirection.rtl)
                          ],
                        ))
                      : setUpLoading(_activities.length)),
            ),
    );
  }

  Widget setUpLoading(user) {
    switch (user) {
      case 0:
        return Center(
            child: Center(
                child: text('There is no any Activity yet.'.tr, Colors.black,
                    23, FontWeight.normal, TextDirection.rtl)));
        break;
      default:
        return ListView.builder(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            shrinkWrap: true,
            itemCount: _activities.length,
            itemBuilder: (BuildContext context, int index) {
              ActivityModel activity = _activities[index];
              return buildActivity(activity);
            });
        break;
    }
  }
}
