import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:weena/APi/apis.dart';
import 'package:weena/Constant/constant.dart';
import 'package:weena/Models/ActivityModel.dart';
import 'package:weena/Models/userModel.dart';
import 'package:weena/Screens/Activites/activites.dart';
import 'package:weena/Screens/Home/Dashbord.dart';

import '../Chats/ListUsers.dart';

class Feed extends StatefulWidget {
  final String? currentUserId;
  final String? visitedUserId;
  final UserModell? userModel;
  final ActivityModel? activityModel;
  const Feed(
      {super.key,
      this.currentUserId,
      this.visitedUserId,
      this.userModel,
      this.activityModel});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  int _selectedIndex = 0; //New
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool user = FirebaseAuth.instance.currentUser!.isAnonymous;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (!user) {
      APi.getSelfInfo();
      widget.currentUserId == APi.myid;
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      Dashboord(
        currentUserId: widget.currentUserId,
      ),
      ListUsers(
          currentUserId: widget.currentUserId,
          visitedUserId: widget.visitedUserId),
      // SearchSC(
      //   fromDashdboard: false,
      //   currentUserId: widget.currentUserId,
      //   fromDashdboardTags: "",
      // ),
      const ActivitesScreen(),
    ];
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: GNav(
        tabBorderRadius: 25,
        backgroundColor: const Color.fromARGB(185, 255, 255, 255),
        color: const Color.fromARGB(255, 92, 92, 92),
        activeColor: whiteColor,
        tabBackgroundColor: moviePageColor,
        gap: 2,
        padding: const EdgeInsets.all(13),
        tabMargin: const EdgeInsets.all(8),
        tabs: [
          GButton(
            icon: Icons.home,
            text: 'Home'.tr,
          ),
          GButton(
            icon: CupertinoIcons.chat_bubble_2_fill,
            iconSize: 30,
            text: 'چاتەکان'.tr,
          ),
          GButton(
            icon: Icons.favorite,
            text: "Activity's".tr,
          ),
        ],
        onTabChange: _onItemTapped,
      ),
    );
  }
}
