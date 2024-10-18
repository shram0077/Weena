import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:weena/APi/apis.dart';
import 'package:weena/Constant/constant.dart';
import 'package:weena/Models/userModel.dart';
import 'package:weena/Screens/Profile/profile.dart';
import 'package:weena/Services/DatabaseServices.dart';
import 'package:weena/encryption_decryption/encryption.dart';
import '../../../Widgets/widget.dart';

class ViewFollowersandFollowing extends StatefulWidget {
  final String currentUserId;
  final String visitedUserId;

  const ViewFollowersandFollowing(
      {super.key, required this.currentUserId, required this.visitedUserId});
  @override
  State<ViewFollowersandFollowing> createState() =>
      _ViewFollowersandFollowingState();
}

class _ViewFollowersandFollowingState extends State<ViewFollowersandFollowing> {
  Stream<List<UserModell>>? _followerUsersStream;
  Stream<List<UserModell>>? _followingUsersStream;

  @override
  void initState() {
    super.initState();
    _followingUsersStream =
        DatabaseServices.getFollowingUsersStream(widget.visitedUserId);
    _followerUsersStream =
        DatabaseServices.getFollowerUsersStream(widget.visitedUserId);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          elevation: 0.4,
          title: text("شوێنکەوان و بەدواداچووەکان", Colors.black, 18,
              FontWeight.normal, TextDirection.rtl),
          titleSpacing: 5,
          automaticallyImplyLeading: false,
          backgroundColor: whiteColor,
          centerTitle: true,
          leading: backButton(context, 23),
          surfaceTintColor: moviePageColor,
          bottom: TabBar(
              indicatorWeight: 2.5,
              indicatorColor: moviePageColor,
              tabs: [
                Tab(
                  child: text("Followers".tr, Colors.black, 14,
                      FontWeight.normal, TextDirection.rtl),
                ),
                Tab(
                  child: text("Following".tr, Colors.black, 14,
                      FontWeight.normal, TextDirection.rtl),
                ),
              ]),
        ),
        body: TabBarView(
          // ignore: sort_child_properties_last
          children: [buildFollowers(), buildFollwing()],
          physics: const NeverScrollableScrollPhysics(),
        ),
      ),
    );
  }

// Following Tab
  Widget buildFollwing() {
    return StreamBuilder<List<UserModell>>(
      stream: _followingUsersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircleProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          List<UserModell> followerUsers = snapshot.data ?? [];
          return ListView.builder(
            itemCount: followerUsers.length,
            itemBuilder: (context, index) {
              UserModell user = followerUsers[index];
              return Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: buildTile(user));
            },
          );
        }
      },
    );
  }

// Followers Tab
  Widget buildFollowers() {
    return StreamBuilder<List<UserModell>>(
      stream: _followerUsersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircleProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          List<UserModell> followerUsers = snapshot.data ?? [];
          return ListView.builder(
            itemCount: followerUsers.length,
            itemBuilder: (context, index) {
              UserModell user = followerUsers[index];
              return Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: buildTile(user));
            },
          );
        }
      },
    );
  }

  buildTile(UserModell user) {
    return ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: ProfileScreen(
                    userModel: user,
                    currentUserId: APi.myid,
                    visitedUserId: user.id,
                  )));
        },
        leading: Container(
          padding: const EdgeInsets.all(1),
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: profileBGcolor,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 65, 90, 165).withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl:
                  MyEncriptionDecription.decryptWithAESKey(user.profilePicture),
              fit: BoxFit.cover,
              width: 50,
              height: 50,
            ),
          ),
        ),
        title: Row(
          children: [
            text(user.name, Colors.black, 16, FontWeight.w400,
                TextDirection.ltr),
            user.verification ? verfiedBadge(17, 17) : const SizedBox(),
            user.admin ? adminBadge(17, 17) : const SizedBox()
          ],
        ),
        subtitle: text(user.username, shadowColor, 14, FontWeight.normal,
            TextDirection.ltr),
        trailing: user.id == widget.currentUserId
            ? text("Me".tr, whiteColor, 15, FontWeight.bold, TextDirection.rtl)
            : const SizedBox());
  }
}
