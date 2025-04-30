import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:weena_latest/APi/apis.dart';
import 'package:weena_latest/Models/ActivityModel.dart';
import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Models/userModel.dart';
import 'package:weena_latest/Models/Post.dart';
import 'package:weena_latest/Screens/Home/Drawer/BuildDrawer.dart';
import 'package:weena_latest/Screens/Home/HomeAppBar.dart';
import 'package:weena_latest/Screens/Home/View%20All/ViewAll.dart';
import 'package:weena_latest/Screens/Home/buildFeeds/Feeds.dart';
import 'package:weena_latest/Screens/Home/build_Sliders/slider.dart';
import 'package:weena_latest/Screens/Home/recommendedPost.dart';
import 'package:weena_latest/Screens/Home/explorer.dart';
import 'package:weena_latest/Screens/Home/Following_Post.dart';
import 'package:weena_latest/Screens/Search/search.dart';
import 'package:weena_latest/Services/DatabaseServices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:weena_latest/Widgets/widget.dart';

class Dashboord extends StatefulWidget {
  final String? currentUserId;
  final String? visitedUserId;
  final UserModell? userModel;
  final ActivityModel? activityModel;
  const Dashboord({
    Key? key,
    this.currentUserId,
    this.visitedUserId,
    this.userModel,
    this.activityModel,
  }) : super(key: key);
  @override
  State<Dashboord> createState() => _DashboordState();
}

class _DashboordState extends State<Dashboord> with TickerProviderStateMixin {
  Widget buildDisCoverCircle({image, title}) {
    return Padding(
      padding: const EdgeInsets.only(left: 2.0, right: 4),
      child: Column(
        children: [
          Container(
            width: 250,
            height: 160,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: CachedNetworkImageProvider(
                  image,
                )),
                color: appcolor,
                borderRadius: BorderRadius.circular(18)),
          )
        ],
      ),
    );
  }

  List<PostModel> _followingPosts = [];
  List<PostModel> _recommended = [];
  List<PostModel> _explorerPost = [];
  List<PostModel> _animations = [];
  List<PostModel> _anime = [];
  List<PostModel> _dramas = [];
  int _followersCount = 0;
  int _followingCount = 0;
  getFollowersCount() async {
    int followersCount =
        await DatabaseServices.followersNumber(_auth.currentUser!.uid);
    if (mounted) {
      setState(() {
        _followersCount = followersCount;
      });
    }
  }

  getFollowingCount() async {
    int followingCount =
        await DatabaseServices.followingNumber(_auth.currentUser!.uid);
    if (mounted) {
      setState(() {
        _followingCount = followingCount;
      });
    }
  }

  getFollowingUserPosts() async {
    setState(() {
      _resreshing = true;
    });
    List<PostModel> userPosts =
        await DatabaseServices.getFollowingPosts(_auth.currentUser!.uid);
    if (mounted) {
      setState(() {
        _followingPosts = userPosts.toList();
        _resreshing = false;
      });
    }
  }

  getRecommendedPost() async {
    setState(() {
      _resreshing = true;
    });
    List<PostModel> recommendedPosts =
        await DatabaseServices.getRecommendedPost();
    if (mounted) {
      setState(() {
        _recommended = recommendedPosts.toList();
        _resreshing = false;
      });
    }
  }

  getAnimes() async {
    List<PostModel> animesPosts = await DatabaseServices.getRecommendedPost();
    if (mounted) {
      setState(() {
        _anime =
            animesPosts.where((element) => element.type == "Anime").toList();
      });
    }
  }

  getExplorerPost() async {
    setState(() {
      _resreshing = true;
    });
    List<PostModel> explorerPost = await DatabaseServices.getExplorerPost();
    if (mounted) {
      setState(() {
        _explorerPost = explorerPost.toList();
        _resreshing = false;
      });
    }
  }

  getAnimations() async {
    List<PostModel> animations = await DatabaseServices.getAnimations();
    if (mounted) {
      setState(() {
        _animations =
            animations.where((element) => element.type == "Animation").toList();
      });
    }
  }

  getDramas() async {
    setState(() {
      _resreshing = true;
    });
    List<PostModel> dramas = await DatabaseServices.getDramas();
    if (mounted) {
      setState(() {
        _dramas = dramas.where((element) => element.type == "Drama").toList();
        _resreshing = false;
      });
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool user = FirebaseAuth.instance.currentUser!.isAnonymous;
  String version = "";
  void getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  void registerMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.notification?.body}');
      // Handle the incoming message and show a notification.
      //
    });
  }

  @override
  void initState() {
    DatabaseServices.checkVersion(context);
    if (user) {
      print('Guest');
    } else {
      APi.getSelfInfo();

      print('SignedIn');
    }
    if (!user) {
      APi.getSelfInfo();
      getFollowersCount();
      getFollowingCount();
    } else {
      print("object");
    }

    if (!user) {
      registerMessageHandler();
    } else {}
    if (!user) {
      _firebaseMessaging.requestPermission();
      _firebaseMessaging.getToken().then((token) {
        usersRef.doc(widget.currentUserId).update({"pushToken": token});
        // Save the token to your server for sending notifications.
        // token: ez01sYiCR_Kp0FAMp-a7NZ:APA91bGzYOgX4d_B3k82bPIgEcOwZ2XvKTDGwoENpHE2O-hWqNJAOjqAlITunzZuBt5p52DGJCXynOXWpqYodP-sxF8_9CHzSkMTPHpfTDyijw6VSga6vPcDsb-DLuTcmANxSpicXPt-
        print("Pushtoken: $token");
      });
      APi.getSelfInfo();
    } else {}
    _tabController = new TabController(
      vsync: this,
      length: 2,
    );
    _tabController!.addListener(_handleTabSelection);
    // TODO: implement initState
    super.initState();

    getAppVersion();
    _auth.currentUser!.uid;

    if (user) {
      getExplorerPost();
      getRecommendedPost();
      getDramas();
      getAnimations();
    } else {
      APi.getSelfInfo();

      getFollowingUserPosts();
      getExplorerPost();
      getRecommendedPost();
      getDramas();
      getAnimations();
    }
  }

  bool _resreshing = false;
  Future<void> refreshDatas() async {
    if (user) {
      getExplorerPost();
      getRecommendedPost();
      getDramas();
      getAnimations();
    } else {
      getFollowingUserPosts();

      getExplorerPost();
      getRecommendedPost();
      getDramas();
      getAnimations();
    }
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  final List<Widget> myTabs = [
    text("وینەکان", appBarColor, 15, FontWeight.normal, TextDirection.rtl),
    text("فییدەکان", appBarColor, 15, FontWeight.normal, TextDirection.rtl),
  ];
  TabController? _tabController;
  _handleTabSelection() {
    if (_tabController!.indexIsChanging) {
      setState(() {});
    }
  }

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture:
          _auth.currentUser!.isAnonymous ? false : true,
      drawer: BuildDrawer(
          version: version,
          followersCount: _followersCount,
          followingCount: _followingCount),
      backgroundColor: whiteColor,
      body: RefreshIndicator(
        color: const Color.fromARGB(255, 123, 105, 105),
        backgroundColor: moviePageColor,
        onRefresh: refreshDatas,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.5),
          child: ListView(
            shrinkWrap: true,
            children: [
              SearchBarr(
                user: user,
                currentUserId: _auth.currentUser!.uid,
              ),
              SizedBox(
                height: 3,
              ),
              TabBar(
                labelPadding: const EdgeInsets.all(5),
                controller: _tabController,
                labelColor: moviePageColor,
                automaticIndicatorColorAdjustment: true,
                indicatorColor: moviePageColor,
                dividerColor: moviePageColor,
                unselectedLabelStyle: const TextStyle(color: whiteColor),
                isScrollable: false,
                tabs: myTabs,
                enableFeedback: true,
                splashBorderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                onTap: (int index) {
                  setState(() {
                    selectedIndex = index;
                    _tabController!.animateTo(index);
                    print(index);
                  });
                },
              ),
              _resreshing
                  ? Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                      ),
                      child: LinearProgressIndicator(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        backgroundColor: moviePageColor,
                        minHeight: 1.5,
                      ),
                    )
                  : const SizedBox(),
              if (_tabController!.index == 1) BuildFeeds() else buildWeenas(),
            ],
          ),
        ),
      ),
    );
  }

  buildWeenas() {
    return Column(
      children: [
        SizedBox(
          height: 3,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            textDirection: TextDirection.rtl,
            children: List.generate(tags.length, (index) {
              return Padding(
                padding: const EdgeInsets.all(6.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: SearchSC(
                              fromDashdboard: true,
                              currentUserId: widget.currentUserId,
                              fromDashdboardTags: tags[index],
                            )));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: moviePageColor,
                    ),
                    child: text(tags[index].tr, whiteColor, 13,
                        FontWeight.normal, TextDirection.rtl),
                  ),
                ),
              );
            }),
          ),
        ),
        Divider(
          color: const Color.fromARGB(255, 131, 131, 131),
          indent: 3.5,
          endIndent: 3.5,
          thickness: 0.3,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              text("شرۆڤەکان", appBarColor.withOpacity(0.9), 15.5,
                  FontWeight.normal, TextDirection.rtl),
            ],
          ),
          // ignore: prefer_const_constructors
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5.0, bottom: 3),
          child: BuildSlider(),
        ),
        _followingPosts.isEmpty
            ? const SizedBox()
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.bottomToTop,
                                child: ViewAllPost(
                                  postModel: _followingPosts,
                                  title: 'Following',
                                  currentuserId: widget.currentUserId!,
                                )));
                      },
                      child: text("View All", appBarColor.withOpacity(0.8),
                          11.5, FontWeight.normal, TextDirection.rtl),
                    ),
                    text("Following", appBarColor.withOpacity(0.9), 15.5,
                        FontWeight.normal, TextDirection.rtl),
                  ],
                ),
                // ignore: prefer_const_constructors
              ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _followingPosts == 0
              ? const SizedBox()
              : Row(
                  children: List.generate(_followingPosts.length, (index) {
                    return FollowingPost(
                      currentUserId: _auth.currentUser!.uid,
                      postModel: _followingPosts[index],
                    );
                  }),
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.bottomToTop,
                          child: ViewAllPost(
                            postModel: _recommended,
                            currentuserId: _auth.currentUser!.uid,
                            title: 'Recommended',
                          )));
                },
                child: text("View All", appBarColor.withOpacity(0.8), 11.5,
                    FontWeight.normal, TextDirection.rtl),
              ),
              text("Recommended", appBarColor.withOpacity(0.9), 15.5,
                  FontWeight.normal, TextDirection.rtl),
            ],
          ),
          // ignore: prefer_const_constructors
        ),
        SizedBox(
            height: 170,
            width: double.infinity,
            child: Padding(
                padding: const EdgeInsets.only(
                    left: 7.0, bottom: 5, top: 5, right: 5),
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: List.generate(_recommended.length, (index) {
                    return Reccomended(
                      currentUserId: _auth.currentUser!.uid,
                      postModel: _recommended[index],
                    );
                  }),
                ))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.bottomToTop,
                          child: ViewAllPost(
                            title: 'Explore',
                            postModel: _explorerPost,
                            currentuserId: widget.currentUserId!,
                          )));
                },
                child: text("View All", appBarColor.withOpacity(0.8), 11.5,
                    FontWeight.normal, TextDirection.rtl),
              ),
              text("Explore", appBarColor.withOpacity(0.9), 15.5,
                  FontWeight.normal, TextDirection.rtl),
            ],
          ),
          // ignore: prefer_const_constructors
        ),
        SizedBox(
          height: 250,
          width: double.infinity,
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: List.generate(_explorerPost.length, (index) {
              return Explorer(
                currentUserId: _auth.currentUser!.uid,
                postModel: _explorerPost[index],
              );
            }),
          ),
        ),
        _animations.isEmpty
            ? const SizedBox()
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.bottomToTop,
                                child: ViewAllPost(
                                  currentuserId: widget.currentUserId!,
                                  postModel: _animations,
                                  title: 'Animation',
                                )));
                      },
                      child: text("View All", appBarColor.withOpacity(0.8),
                          11.5, FontWeight.normal, TextDirection.rtl),
                    ),
                    text("Animation", appBarColor.withOpacity(0.9), 15.5,
                        FontWeight.normal, TextDirection.rtl),
                  ],
                ),
              ),
        _animations.isEmpty
            ? const SizedBox()
            : SizedBox(
                height: 170,
                width: double.infinity,
                child: Padding(
                    padding: const EdgeInsets.only(
                        left: 7.0, bottom: 5, top: 5, right: 5),
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: List.generate(_animations.length, (index) {
                        return Reccomended(
                          currentUserId: _auth.currentUser!.uid,
                          postModel: _animations[index],
                        );
                      }),
                    ))),
        _anime.isEmpty
            ? const SizedBox()
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.bottomToTop,
                                child: ViewAllPost(
                                  title: 'Anime',
                                  postModel: _explorerPost,
                                  currentuserId: widget.currentUserId!,
                                )));
                      },
                      child: text("View All", appBarColor.withOpacity(0.8),
                          11.5, FontWeight.normal, TextDirection.rtl),
                    ),
                    text("Anime", appBarColor.withOpacity(0.9), 15.5,
                        FontWeight.normal, TextDirection.rtl),
                  ],
                ),
                // ignore: prefer_const_constructors
              ),
        _anime.isEmpty
            ? const SizedBox()
            : SizedBox(
                height: 250,
                width: double.infinity,
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: List.generate(_anime.length, (index) {
                    return Explorer(
                      currentUserId: _auth.currentUser!.uid,
                      postModel: _anime[index],
                    );
                  }),
                ),
              ),
        _dramas.isEmpty
            ? const SizedBox()
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.bottomToTop,
                                child: ViewAllPost(
                                  currentuserId: widget.currentUserId!,
                                  postModel: _dramas,
                                  title: 'Dramas',
                                )));
                      },
                      child: text("View All", appBarColor.withOpacity(0.8),
                          11.5, FontWeight.normal, TextDirection.rtl),
                    ),
                    text("Dramas", appBarColor.withOpacity(0.9), 15.5,
                        FontWeight.normal, TextDirection.rtl),
                  ],
                ),
              ),
        _dramas.isEmpty
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: List.generate(_dramas.length, (index) {
                    return Explorer(
                      currentUserId: _auth.currentUser!.uid,
                      postModel: _dramas[index],
                    );
                  }),
                ),
              ),
      ],
    );
  }
}
