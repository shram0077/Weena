import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emerge_alert_dialog/emerge_alert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:weena/APi/apis.dart';
import 'package:weena/Constant/constant.dart';
import 'package:weena/Models/ActivityModel.dart';
import 'package:weena/Models/Post.dart';
import 'package:weena/Models/linksModel.dart';
import 'package:weena/Models/userModel.dart';
import 'package:weena/Screens/Profile/Settings/Settings.dart';
import 'package:weena/Services/DatabaseServices.dart';
import 'package:weena/Widgets/Feed%20Widgets/FeedContainer.dart';
import 'package:weena/Widgets/PostConatiner.dart';
import 'package:weena/Widgets/profile_ImagePreview.dart';
import 'package:weena/Widgets/widget.dart';
import 'package:weena/encryption_decryption/encryption.dart';
import 'Followers_Following/Followers_Following.dart';

class ProfileScreen extends StatefulWidget {
  final String currentUserId;
  final String visitedUserId;
  final UserModell userModel;

  const ProfileScreen(
      {super.key,
      required this.currentUserId,
      required this.visitedUserId,
      required this.userModel});
  @override
  State<ProfileScreen> createState() => _ProfileScreensState();
}

class _ProfileScreensState extends State<ProfileScreen> {
  bool _isFollowing = false;
  bool _blockingUser = false;
  bool _ismeBlocked = false;
  int _followersCount = 0;
  int _followingCount = 0;
  bool _isAddingCollectionsUser = false;
  String uuidChat = const Uuid().v1();
  String activityid = const Uuid().v4();
  dynamic _profileSegmentedValue = 0;
  var key;
  List<PostModel> _allPosts = [];
  List<PostModel> _drama = [];
  List<PostModel> _movie = [];
  List<PostModel> _series = [];
  bool user = FirebaseAuth.instance.currentUser!.isAnonymous;
  ActivityModel? activityModel;
  getFollowersCount() async {
    _isRefreshing = true;
    int followersCount =
        await DatabaseServices.followersNumber(widget.visitedUserId);
    if (mounted) {
      setState(() {
        _followersCount = followersCount;
        _isRefreshing = false;
      });
    }
  }

  getFollowingCount() async {
    _isRefreshing = true;
    int followingCount =
        await DatabaseServices.followingNumber(widget.visitedUserId);
    if (mounted) {
      setState(() {
        _followingCount = followingCount;
        _isRefreshing = false;
      });
    }
  }

  followOrUnFollow() {
    if (_isFollowing) {
      _showUnfollowDialog(context);
      // unFollowUser();
    } else {
      followUser();
      APi.sendFollowPushNotification(widget.userModel.pushToken);
    }
  }

  createCollectionOrRemove() {
    if (_isAddingCollectionsUser) {
      DatabaseServices.removeCollection(
          widget.currentUserId, widget.visitedUserId);
    } else {
      DatabaseServices.createCollection(
        widget.currentUserId,
        widget.visitedUserId,
      );
      APi.sendAddedPushNotification(widget.userModel.pushToken);
    }
  }

  unFollowUser() {
    DatabaseServices.unFollowUser(
        widget.currentUserId, widget.visitedUserId, activityid);
    setState(() {
      _isFollowing = false;
      _followersCount--;
    });
  }

  followUser() {
    DatabaseServices.followUser(
      widget.currentUserId,
      widget.visitedUserId,
      activityid,
    );
    setState(() {
      _isFollowing = true;
      _followersCount++;
    });
  }

  setUpCollection() async {
    bool isCreatedCollection = await DatabaseServices.isCollectionCreated(
        widget.currentUserId, widget.visitedUserId);
    setState(() {
      _isAddingCollectionsUser = isCreatedCollection;
    });
  }

  setupIsFollowing() async {
    _isRefreshing = true;
    bool isFollowingThisUser = await DatabaseServices.isFollowingUser(
        widget.currentUserId, widget.visitedUserId);
    setState(() {
      _isFollowing = isFollowingThisUser;
      _isRefreshing = false;
    });
  }

  setupisBlocking() async {
    bool isBlockingThisUser = await DatabaseServices.isBlockingUser(
        widget.currentUserId, widget.visitedUserId);
    setState(() {
      _blockingUser = isBlockingThisUser;
    });
  }

  setupismeBlocking() async {
    bool ismeBlocked = await DatabaseServices.isMeBlocked(
        widget.currentUserId, widget.visitedUserId);
    setState(() {
      _ismeBlocked = ismeBlocked;
    });
  }

  PaletteGenerator? paletteGenerator;
  void _genrateColors() async {
    paletteGenerator = await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(MyEncriptionDecription.decryptWithAESKey(
            widget.userModel.profilePicture)));
  }

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
    DatabaseServices.checkVersion(context);

    fetchAds();
    super.initState();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchAds();
    });
    if (widget.userModel.coverPicture.isNotEmpty) {
      _genrateColors();
    } else {}

    setupIsFollowing();
    getFollowersCount();
    getFollowingCount();
    setupisBlocking();
    setupismeBlocking();
    getAllPosts();
    setUpCollection();
    _followersCount = _followersCount;
    _followingCount = _followingCount;
    _isAddingCollectionsUser = _isAddingCollectionsUser;
    _drama = _drama;
    _movie = _movie;
    _allPosts = _allPosts;
  }

  bool _isRefreshing = false;
  Future<void> refreshAllData() async {
    setState(() {
      getFollowersCount();
      getFollowingCount();
      setupIsFollowing();
      setupisBlocking();
      setupismeBlocking();
      getAllPosts();
      if (widget.userModel.coverPicture.isNotEmpty) {
        _genrateColors();
      } else {}
    });
  }

  getAllPosts() async {
    _isRefreshing = true;
    List<PostModel> userPosts =
        await DatabaseServices.getUserPosts(widget.visitedUserId);
    if (mounted) {
      setState(() {
        _allPosts = userPosts;
        _drama = _allPosts.where((element) => element.type == 'Drama').toList();
        _movie = _allPosts.where((element) => element.type == 'Movie').toList();
        _series =
            _allPosts.where((element) => element.type == 'Series').toList();
        _isRefreshing = false;
      });
    }
  }

  // ignore: prefer_final_fields
  Map<int, Widget> _profileTabs = <int, Widget>{
    0: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: text("All", whiteColor, 13, FontWeight.normal, TextDirection.rtl),
    ),
    1: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: text("فیید", whiteColor, 13, FontWeight.normal, TextDirection.rtl),
    ),
    2: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child:
          text("Movies", whiteColor, 13, FontWeight.normal, TextDirection.rtl),
    ),
    3: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child:
          text("Dramas", whiteColor, 13, FontWeight.normal, TextDirection.rtl),
    ),
    4: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child:
          text("Series", whiteColor, 13, FontWeight.normal, TextDirection.rtl),
    ),
  };
// Verifed User
  final Map<int, Widget> _profileTabsForVerifedUser = <int, Widget>{
    0: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: text("All", whiteColor, 13, FontWeight.normal, TextDirection.rtl),
    ),
    1: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child:
          text("Movies", whiteColor, 13, FontWeight.normal, TextDirection.rtl),
    ),
    2: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child:
          text("Dramas", whiteColor, 13, FontWeight.normal, TextDirection.rtl),
    ),
    3: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child:
          text("Series", whiteColor, 13, FontWeight.normal, TextDirection.rtl),
    ),
  };

  Widget buildProfileWidgets(UserModell author) {
    switch (_profileSegmentedValue) {
      case 0:
        return GridView.builder(
            physics:
                const ScrollPhysics(parent: NeverScrollableScrollPhysics()),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18),
            itemCount: _allPosts.length,
            itemBuilder: (BuildContext ctx, index) {
              return PostConatiner(
                currentUserId: widget.currentUserId,
                postModel: _allPosts[index],
                userModell: author,
              );
            });
        break;
      case 1:
        return StreamBuilder(
            stream: feedsRef
                .doc(widget.visitedUserId)
                .collection('Feeds')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.only(top: 48.0),
                  child: Center(
                    child: CircleProgressIndicator(),
                  ),
                );
              }

              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(snapshot.data!.docs.length, (index) {
                  return FeedContainer(
                      fromProfile: true,
                      currentUserId: widget.currentUserId,
                      description: snapshot.data!.docs[index]['description'],
                      refeed: snapshot.data!.docs[index]['refeed'],
                      likes: snapshot.data!.docs[index]['likes'],
                      pictures: snapshot.data!.docs[index]['images'],
                      timestamp: snapshot.data!.docs[index]['timestamp'],
                      userModell: widget.userModel,
                      postId: snapshot.data!.docs[index]['postId'],
                      ownerId: snapshot.data!.docs[index]['ownerId']);
                }),
              );
            });

        break;
      case 2:
        return GridView.builder(
            physics:
                const ScrollPhysics(parent: NeverScrollableScrollPhysics()),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18),
            itemCount: _movie.length,
            itemBuilder: (BuildContext ctx, index) {
              return PostConatiner(
                currentUserId: widget.currentUserId,
                postModel: _movie[index],
                userModell: author,
              );
            });
        break;
      case 3:
        return GridView.builder(
            physics:
                const ScrollPhysics(parent: NeverScrollableScrollPhysics()),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18),
            itemCount: _drama.length,
            itemBuilder: (BuildContext ctx, index) {
              return PostConatiner(
                currentUserId: widget.currentUserId,
                postModel: _drama[index],
                userModell: author,
              );
            });

        break;
      case 4:
        return GridView.builder(
            physics:
                const ScrollPhysics(parent: NeverScrollableScrollPhysics()),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18),
            itemCount: _series.length,
            itemBuilder: (BuildContext ctx, index) {
              return PostConatiner(
                currentUserId: widget.currentUserId,
                postModel: _series[index],
                userModell: author,
              );
            });
        break;
      default:
        return Center(
          child: Column(
            children: [
              // ignore: prefer_const_constructors
              Icon(
                CupertinoIcons.camera_circle,
                size: 55,
                color: whiteColor,
              ),
              text('هیچ نییە جارێ', whiteColor, 21, FontWeight.w400,
                  TextDirection.rtl),
            ],
          ),
        );
        break;
    }
  }

  Widget buildProfileWidgetsForVerifedUser(UserModell author) {
    switch (_profileSegmentedValue) {
      case 0:
        return GridView.builder(
            physics:
                const ScrollPhysics(parent: NeverScrollableScrollPhysics()),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18),
            itemCount: _allPosts.length,
            itemBuilder: (BuildContext ctx, index) {
              return PostConatiner(
                currentUserId: widget.currentUserId,
                postModel: _allPosts[index],
                userModell: author,
              );
            });
        break;

      case 1:
        return GridView.builder(
            physics:
                const ScrollPhysics(parent: NeverScrollableScrollPhysics()),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18),
            itemCount: _movie.length,
            itemBuilder: (BuildContext ctx, index) {
              return PostConatiner(
                currentUserId: widget.currentUserId,
                postModel: _movie[index],
                userModell: author,
              );
            });
        break;
      case 2:
        return GridView.builder(
            physics:
                const ScrollPhysics(parent: NeverScrollableScrollPhysics()),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18),
            itemCount: _drama.length,
            itemBuilder: (BuildContext ctx, index) {
              return PostConatiner(
                currentUserId: widget.currentUserId,
                postModel: _drama[index],
                userModell: author,
              );
            });

        break;
      case 3:
        return GridView.builder(
            physics:
                const ScrollPhysics(parent: NeverScrollableScrollPhysics()),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18),
            itemCount: _series.length,
            itemBuilder: (BuildContext ctx, index) {
              return PostConatiner(
                currentUserId: widget.currentUserId,
                postModel: _series[index],
                userModell: author,
              );
            });
        break;
      default:
        return Center(
          child: Column(
            children: [
              // ignore: prefer_const_constructors
              Icon(
                CupertinoIcons.camera_circle,
                size: 55,
                color: whiteColor,
              ),
              text('هیچ نییە جارێ', whiteColor, 21, FontWeight.w400,
                  TextDirection.rtl),
            ],
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: whiteColor,
        resizeToAvoidBottomInset: false,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              actions: [
                if (widget.currentUserId != widget.visitedUserId)
                  _ismeBlocked
                      ? const SizedBox()
                      : user
                          ? const SizedBox()
                          : moreVertonProfile(context, widget.currentUserId,
                              widget.visitedUserId, widget.userModel)
                else
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: SettingScreen(
                                  currentUserId: widget.currentUserId,
                                  visitedUserId: widget.visitedUserId,
                                  userModel: widget.userModel,
                                )));
                      },
                      icon: const Icon(
                        CupertinoIcons.settings,
                      ))
              ],
              centerTitle: false,
              backgroundColor: paletteGenerator != null
                  ? paletteGenerator!.vibrantColor != null
                      ? paletteGenerator!.vibrantColor!.color
                      : moviePageColor
                  : moviePageColor.withOpacity(0.8),
              elevation: 0.5,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Padding(
                padding: const EdgeInsets.only(top: 0.0, left: 5),
                child: Text(
                  widget.userModel.username,
                  style: GoogleFonts.barlow(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: appBarColor),
                ),
              ),
              expandedHeight: 180,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: GestureDetector(
                  onTap: () {
                    widget.userModel.coverPicture.isNotEmpty
                        ? Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: ProfileImagePreview(
                                  currentUserId: widget.currentUserId,
                                  visitedUserId: widget.visitedUserId,
                                  URLPicture: widget.userModel.coverPicture,
                                  key: key,
                                )))
                        : null;
                  },
                  child: widget.userModel.coverPicture.isEmpty
                      ? Container(
                          color: const Color.fromARGB(202, 255, 255, 255),
                          height: 249,
                        )
                      : Container(
                          height: 249,
                          decoration: BoxDecoration(
                            color: appBarColor.withOpacity(0.7),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                MyEncriptionDecription.decryptWithAESKey(
                                    widget.userModel.coverPicture),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            )
          ],
          body: RefreshIndicator(
            onRefresh: () => refreshAllData(),
            backgroundColor: paletteGenerator != null
                ? paletteGenerator!.vibrantColor != null
                    ? paletteGenerator!.vibrantColor!.color
                    : moviePageColor
                : moviePageColor.withOpacity(0.8),
            color: Colors.white,
            child: StreamBuilder(
              stream: usersRef.doc(widget.visitedUserId).snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 300.0),
                    child: Center(child: CircleProgressIndicator()),
                  );
                  // ignore: unrelated_type_equality_checks
                } else if (snapshot == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 300.0),
                    child: Center(child: CircleProgressIndicator()),
                  );
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
                  physics: const ScrollPhysics(
                      parent: NeverScrollableScrollPhysics()),
                  children: [
                    Container(
                      transform: Matrix4.translationValues(0.0, -25.0, 0.0),
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _isRefreshing
                              ? Center(
                                  child: CircleProgressIndicator(),
                                )
                              : const SizedBox(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Stack(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 0, left: 3),
                                    child: normalAvatar(
                                        userModel,
                                        context,
                                        widget.currentUserId,
                                        widget.visitedUserId,
                                        key,
                                        100,
                                        100,
                                        15),
                                  )
                                ],
                              ),
                              widget.currentUserId == widget.visitedUserId
                                  ? userModel.isVerified
                                      ? buildCreateButton(
                                          context, widget.currentUserId)
                                      : const SizedBox()
                                  : _blockingUser
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              DatabaseServices.unblockUser(
                                                  widget.currentUserId,
                                                  userModel.id);
                                              setState(() {
                                                refreshAllData();
                                              });
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 7),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: errorColor,
                                                border: Border.all(
                                                    color: errorColor,
                                                    width: 2),
                                              ),
                                              child: Center(
                                                child: text(
                                                    "لابردنی بلۆک",
                                                    whiteColor,
                                                    16,
                                                    FontWeight.bold,
                                                    TextDirection.rtl),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              user != true
                                                  ? _blockingUser
                                                      ? null
                                                      : _ismeBlocked
                                                          ? Fluttertoast.showToast(
                                                              msg:
                                                                  "${userModel.name}بلۆکی کردووی",
                                                              backgroundColor:
                                                                  appcolor)
                                                          : followOrUnFollow()
                                                  : Fluttertoast.showToast(
                                                      msg:
                                                          'پێویستە چونەژوورەوەت ئەنجام دابێت',
                                                      backgroundColor:
                                                          moviePageColor,
                                                      textColor: whiteColor);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                  top: 4,
                                                  bottom: 4,
                                                  right: 10,
                                                  left: 9),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: _isFollowing
                                                    ? moviePageColor
                                                    : const Color.fromARGB(
                                                        255, 74, 92, 113),
                                                border: Border.all(
                                                    color: whiteColor,
                                                    width: 1),
                                              ),
                                              child: Center(
                                                child: _ismeBlocked
                                                    ? const Icon(
                                                        FlutterIcons.md_sad_ion,
                                                        color: Colors.white)
                                                    : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          _isFollowing
                                                              ? const Icon(
                                                                  Icons.check,
                                                                  color:
                                                                      whiteColor,
                                                                )
                                                              : const SizedBox(),
                                                          text(
                                                              _isFollowing
                                                                  ? 'Unfollow'
                                                                  : 'Follow',
                                                              whiteColor,
                                                              14,
                                                              FontWeight.w500,
                                                              TextDirection
                                                                  .rtl),
                                                        ],
                                                      ),
                                              ),
                                            ),
                                          ),
                                        )
                            ],
                          ),
                          displayName(userModel),
                          userNameProfile(userModel),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.topToBottom,
                                          child: ViewFollowersandFollowing(
                                            currentUserId: widget.currentUserId,
                                            visitedUserId: widget.visitedUserId,
                                            key: key,
                                          )));
                                },
                                child: followingandFollowers(
                                    _followingCount, _followersCount),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: _blockingUser
                                    ? const SizedBox()
                                    : buildSocialButtons(),
                              ),
                            ],
                          ),
                          userModel.bio.isEmpty
                              ? const SizedBox()
                              : _blockingUser
                                  ? const SizedBox()
                                  : bio(userModel, context),
                          const SizedBox(
                            height: 1,
                          ),
                          _blockingUser
                              ? const SizedBox()
                              : profilelocation(userModel, context),
                          const SizedBox(
                            height: 1,
                          ),
                          userModel.bio.isNotEmpty
                              ? const Divider()
                              : const SizedBox(),
                          _blockingUser
                              ? const SizedBox()
                              : SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: CupertinoSlidingSegmentedControl(
                                    groupValue: _profileSegmentedValue,
                                    thumbColor: moviePageColor,
                                    backgroundColor:
                                        const Color.fromARGB(255, 74, 92, 113),
                                    children: widget.userModel.isVerified
                                        ? _profileTabs
                                        : _profileTabsForVerifedUser,
                                    onValueChanged: (i) {
                                      setState(() {
                                        _profileSegmentedValue = i;
                                      });
                                    },
                                  ),
                                ),
                          _ismeBlocked
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 50.0),
                                  child: Center(
                                    child: text(
                                        'You has been blocked!',
                                        whiteColor,
                                        21,
                                        FontWeight.w400,
                                        TextDirection.rtl),
                                  ),
                                )
                              : Padding(
                                  padding: EdgeInsets.only(
                                      top: _blockingUser ? 20 : 8.0,
                                      bottom: 8,
                                      left: 5,
                                      right: 5),
                                  child: _blockingUser
                                      ? Center(
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                color:
                                                    errorColor.withOpacity(0.5),
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: text(
                                                "${userModel.username} بلۆکە",
                                                whiteColor,
                                                20,
                                                FontWeight.w500,
                                                TextDirection.rtl),
                                          ),
                                        )
                                      : userModel.isVerified
                                          ? buildProfileWidgets(userModel)
                                          : buildProfileWidgetsForVerifedUser(
                                              userModel),
                                ),
                          _movie.length > 5
                              ? Center(
                                  child: text("ڕیکلام", shadowColor, 13,
                                      FontWeight.normal, TextDirection.rtl),
                                )
                              : const SizedBox(),
                          _movie.length > 5
                              ? admIMG != null
                                  ? buildAds(admIMG, onClickLink)
                                  : const SizedBox()
                              : const SizedBox()
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ));
  }

  Future<void> _showUnfollowDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return EmergeAlertDialog(
          alignment: Alignment.topCenter,
          emergeAlertDialogOptions: EmergeAlertDialogOptions(
              backgroundColor: const Color.fromARGB(255, 30, 28, 28),
              title: text("دڵنیای لە شوێن نەکەوتنی ${widget.userModel.name}",
                  whiteColor, 18, FontWeight.normal, TextDirection.rtl),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: text("نەخێر", whiteColor.withOpacity(0.9), 18,
                      FontWeight.w500, TextDirection.rtl),
                ),
                MaterialButton(
                  onPressed: () {
                    unFollowUser();
                    Navigator.pop(context);
                  },
                  child: text("بەڵێ", redolor.withOpacity(0.9), 18,
                      FontWeight.bold, TextDirection.rtl),
                ),
              ]),
        );
      },
    );
  }

  Widget buildSocialButtons() {
    return StreamBuilder(
        stream: linksRef.doc(widget.visitedUserId).snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircleProgressIndicator());
            // ignore: unrelated_type_equality_checks
          } else if (snapshot == ConnectionState.waiting) {
            return Center(child: CircleProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("کێشەیەک هەیە!",
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.alef(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: errorColor)),
                ],
              ),
            );
          }

          LinksModel linksModel = LinksModel.fromDoc(snapshot.data);
          return Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 5, right: 5),
            child: Row(
              children: [
                linksModel.youtube.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(left: 3, right: 3),
                        child: GestureDetector(
                          onTap: () async {
                            var url = linksModel.youtube;
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              print('Could not launch $url');
                            }
                          },
                          child: socialMediaButton(
                              Colors.red, FontAwesome.youtube_play),
                        ))
                    : const SizedBox(),
                if (linksModel.facebook.isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.only(left: 3, right: 3),
                      child: GestureDetector(
                        onTap: () async {
                          var url = linksModel.facebook;
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            print('Could not launch $url');
                          }
                        },
                        child: socialMediaButton(
                            Colors.blue, FontAwesome.facebook),
                      ))
                else
                  const SizedBox(),
                if (linksModel.instagram.isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.only(left: 3, right: 3),
                      child: GestureDetector(
                        onTap: () async {
                          var url = linksModel.instagram;
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            print('Could not launch $url');
                          }
                        },
                        child: socialMediaButton(
                            const Color.fromARGB(255, 244, 45, 111),
                            FontAwesome.instagram),
                      ))
                else
                  const SizedBox()
              ],
            ),
          );
        });
  }

  Widget moreVertonProfile(context, String currentUserId, String visitedUserId,
      UserModell userModel) {
    return PopupMenuButton(
        icon: const Icon(
          FlutterIcons.more_vert_mdi,
        ),
        shadowColor: paletteGenerator != null
            ? paletteGenerator!.vibrantColor != null
                ? paletteGenerator!.vibrantColor!.color
                : appBarColor.withOpacity(0.2)
            : appBarColor.withOpacity(0.2),
        elevation: 20,
        itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  setState(() {
                    createCollectionOrRemove();
                    setUpCollection();

                    _isAddingCollectionsUser = _isAddingCollectionsUser;
                  });
                },
                value: 1,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        _isAddingCollectionsUser
                            ? CupertinoIcons.clear
                            : CupertinoIcons.chat_bubble_text,
                        color: Colors.black,
                      ),
                    ),
                    Text(_isAddingCollectionsUser
                        ? "سڕینەوە لە لیستی چات"
                        : "زیادکردن بۆ لیستی چات"),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () {
                  if (!_blockingUser) {
                    DatabaseServices.blockUser(
                        currentUserId, visitedUserId, 'null');
                    setState(() {
                      _blockingUser = true;
                      setupisBlocking();
                      getFollowersCount();
                      getFollowingCount();
                      setupIsFollowing();
                      setupismeBlocking();
                    });
                  } else {
                    DatabaseServices.unblockUser(currentUserId, visitedUserId);
                    setState(() {
                      _blockingUser = false;
                    });
                  }
                },
                value: 2,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        _blockingUser
                            ? FlutterIcons.circle_outline_mco
                            : FlutterIcons.block_mdi,
                        color: Colors.black,
                      ),
                    ),
                    Text(_blockingUser
                        ? "سڕینەوە لەناو گەیالەکە"
                        : 'بۆ ناو گەیالەکە'),
                  ],
                ),
              ),
            ]);
  }
}
