import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:weena_latest/APi/apis.dart';
import 'package:weena_latest/Models/ActivityModel.dart';
import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Models/userModel.dart';
import 'package:weena_latest/Models/Post.dart';
import 'package:weena_latest/Screens/Home/Dashboard/Weenas.dart';
import 'package:weena_latest/Screens/Home/Drawer/BuildDrawer.dart';
import 'package:weena_latest/Screens/Home/HomeAppBar.dart';
import 'package:weena_latest/Screens/Home/buildFeeds/Feeds.dart';
import 'package:weena_latest/Services/DatabaseServices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final List<Widget> myTabs = [
    text("وینەکان", whiteColor, 15, FontWeight.normal, TextDirection.rtl),
    text("فییدەکان", whiteColor, 15, FontWeight.normal, TextDirection.rtl),
  ];

  TabController? _tabController;
  List<PostModel> _movies = [];
  List<PostModel> _popularityMovies = [];
  int _followersCount = 0;
  int _followingCount = 0;
  String version = "";
  bool _refreshing = false;

  bool get isGuest => _auth.currentUser?.isAnonymous ?? true;

  @override
  void initState() {
    super.initState();
    DatabaseServices.checkVersion(context);

    _tabController = TabController(vsync: this, length: 2)
      ..addListener(_handleTabSelection);

    getMovies();
    getPopularityMovies();
    if (!isGuest) {
      print('SignedIn');
      APi.getSelfInfo();
      getFollowersCount();
      getFollowingCount();
      registerMessageHandler();

      _firebaseMessaging.requestPermission();
      _firebaseMessaging.getToken().then((token) {
        usersRef.doc(widget.currentUserId).update({"pushToken": token});
        print("Push token: $token");
      });
    } else {
      print('Guest');
    }
  }

  Future<void> getFollowersCount() async {
    int count = await DatabaseServices.followersNumber(_auth.currentUser!.uid);
    if (mounted) setState(() => _followersCount = count);
  }

  Future<void> getFollowingCount() async {
    int count = await DatabaseServices.followingNumber(_auth.currentUser!.uid);
    if (mounted) setState(() => _followingCount = count);
  }

  Future<void> getMovies() async {
    List<PostModel> movies =
        await DatabaseServices.getMovies(); // must fetch from "Weenas"
    if (mounted) setState(() {});
    _movies = movies;
  }

  Future<void> getPopularityMovies() async {
    List<PostModel> movies =
        await DatabaseServices.getPopularMovies(); // must fetch from "Weenas"
    if (mounted) setState(() {});
    _popularityMovies = movies;
  }

  void registerMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.notification?.body}');
    });
  }

  void _handleTabSelection() {
    if (_tabController!.indexIsChanging) {
      setState(() {});
    }
  }

  Future<void> refreshDatas() async {
    setState(() => _refreshing = true);
    await getMovies();
    setState(() => _refreshing = false);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        canvasColor: Colors.black,
        primaryColor: Colors.white,
        indicatorColor: Colors.white,
        colorScheme: const ColorScheme.dark().copyWith(
          primary: Colors.white,
          secondary: Colors.grey,
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      child: Scaffold(
        drawerEnableOpenDragGesture: !isGuest,
        drawer:
            isGuest
                ? null
                : BuildDrawer(
                  version: version,
                  followersCount: _followersCount,
                  followingCount: _followingCount,
                ),
        backgroundColor: Colors.black, // Override again just to be sure
        body: RefreshIndicator(
          color: Colors.white,
          backgroundColor: Colors.black,
          onRefresh: refreshDatas,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.5),
            child: ListView(
              shrinkWrap: true,
              children: [
                SearchBarr(
                  user: isGuest,
                  currentUserId: _auth.currentUser!.uid,
                ),
                const SizedBox(height: 3),
                TabBar(
                  controller: _tabController,
                  labelPadding: const EdgeInsets.all(5),
                  labelColor: Colors.white,
                  indicatorColor: Colors.white,
                  dividerColor: Colors.white24,
                  unselectedLabelColor: Colors.white54,
                  tabs: myTabs,
                  enableFeedback: true,
                  splashBorderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  onTap: (index) {
                    setState(() => _tabController!.animateTo(index));
                  },
                ),
                if (_refreshing)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: LinearProgressIndicator(
                      color: Colors.white,
                      backgroundColor: Colors.grey,
                      minHeight: 1.5,
                    ),
                  ),
                _tabController!.index == 1
                    ? BuildFeeds()
                    : buildWeenas(
                      context,
                      tags,
                      _movies,
                      _popularityMovies,
                      widget.currentUserId!,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
