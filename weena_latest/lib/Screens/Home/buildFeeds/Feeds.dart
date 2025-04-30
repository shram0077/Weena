import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Models/FeedModel.dart';
import 'package:weena_latest/Models/userModel.dart';
import 'package:weena_latest/Screens/Home/buildFeeds/FeedLoading.dart';
import 'package:weena_latest/Services/DatabaseServices.dart';
import 'package:weena_latest/Widgets/Feed%20Widgets/FeedContainer.dart';
import 'package:weena_latest/Widgets/widget.dart';

class BuildFeeds extends StatefulWidget {
  @override
  State<BuildFeeds> createState() => _BuildFeedsState();
}

class _BuildFeedsState extends State<BuildFeeds> {
  var currentUserId = FirebaseAuth.instance.currentUser!.uid;
  List<FeedModel> _feeds = [];

  Future getFeeds() async {
    List<FeedModel> userPosts = await DatabaseServices.getFeeds(currentUserId);
    if (mounted) {
      setState(() {
        _feeds = userPosts;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFeeds();
  }

  bool isAnonyousUser = FirebaseAuth.instance.currentUser!.isAnonymous;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: isAnonyousUser
          ? shouldbeSignedup(context, true)
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _feeds.length,
              itemBuilder: (BuildContext context, int index) {
                FeedModel feedModel = _feeds[index];
                return StreamBuilder(
                    stream: usersRef.doc(feedModel.ownerId).snapshots(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return const FeedLoading();
                        // ignore: unrelated_type_equality_checks
                      } else if (snapshot == ConnectionState.waiting) {
                        return const FeedLoading();
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
                      return FeedContainer(
                          fromProfile: false,
                          userModell: userModel,
                          description: feedModel.description,
                          pictures: feedModel.pictures,
                          likes: feedModel.likes,
                          refeed: feedModel.refeed,
                          timestamp: feedModel.timestamp,
                          currentUserId: currentUserId,
                          ownerId: feedModel.ownerId,
                          postId: feedModel.postuid);
                    });
              }),
    );
  }
}
