import 'dart:async';
import 'package:animated_digit/animated_digit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emerge_alert_dialog/emerge_alert_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:weena_latest/APi/apis.dart';
import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Models/Post.dart';
import 'package:weena_latest/Models/userModel.dart';
import 'package:weena_latest/Screens/MoviePage/Comment/comment.dart';
import 'package:weena_latest/Screens/MoviePage/OtherParts.dart';
import 'package:weena_latest/Screens/MoviePage/Video_Player/utils.dart';
import 'package:weena_latest/Screens/MoviePage/movie_page.dart';
import 'package:weena_latest/Services/DatabaseServices.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pod_player/pod_player.dart';
import 'package:uuid/uuid.dart';
import 'package:weena_latest/Widgets/widget.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class VideoPlayer extends StatefulWidget {
  final PostModel postModel;
  final String currentUserId;
  final UserModell userModell;
  final bool isAnonymous;
  final commentCount;
  final bool isFromEpisode;
  final episodeLink;
  final bool isDirectLink;
  const VideoPlayer({
    Key? key,
    required this.postModel,
    required this.currentUserId,
    required this.userModell,
    required this.isAnonymous,
    this.commentCount,
    required this.isFromEpisode,
    this.episodeLink,
    required this.isDirectLink,
  }) : super(key: key);

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  bool _isLiked = false;
  int _likes = 0;
  bool _isFollowing = false;
  String activityid = const Uuid().v4();
  bool loadBanner = false;
  var key;
  var uuid = const Uuid().v4();
  getLikesCount() async {
    int likesCount = await DatabaseServices.getPostLikes(widget.postModel.id);
    if (mounted) {
      setState(() {
        _likes = likesCount;
      });
    }
  }

  likePost() {
    DatabaseServices.likePost(
      widget.postModel.postuid,
      widget.postModel.userId,
      widget.currentUserId,
      widget.postModel.thumbnail,
      false,
    );
    setState(() {
      _isLiked = true;
      _likes++;
    });
  }

  unLikePost() {
    DatabaseServices.unlikePost(
      widget.postModel.id,
      widget.postModel.userId,
      widget.currentUserId,
      widget.postModel.id,
      false,
    );
    setState(() {
      _isLiked = false;
      _likes--;
    });
  }

  likeOrUnlike() {
    if (_isLiked) {
      unLikePost();
    } else {
      likePost();
    }
  }

  setupIsLikedPost() async {
    bool isLikedThisPost = await DatabaseServices.isLikedPost(
      widget.postModel.id,
      widget.currentUserId,
    );
    setState(() {
      _isLiked = isLikedThisPost;
    });
  }

  bool _loading = false;
  List<PostModel> _otherEpisodes = [];

  getSeries() async {
    setState(() {
      _loading = true;
    });
    List<PostModel> getOtherEP = await DatabaseServices.getOtherEpisodes(
      widget.postModel,
    );
    if (mounted) {
      setState(() {
        _otherEpisodes = getOtherEP.toList();
        print(_otherEpisodes.length);
        _loading = false;
      });
    }
  }

  List<PostModel> _recommendedMovies = [];

  getMoviesWithRandomly() async {
    List<PostModel> getmvs =
        await DatabaseServices.getExplorerPostWithRandomly();
    if (mounted) {
      setState(() {
        _recommendedMovies =
            getmvs
                .where((element) => element.type == widget.postModel.type)
                .toList();
      });
    }
  }

  String nextVideo = '';

  bool? podStatus = false;
  bool? meeduStatus = false;

  PodPlayerController? _controller;

  followOrUnFollow() {
    if (_isFollowing) {
      _showUnfollowDialog(context);
      // unFollowUser();
    } else {
      followUser();
    }
  }

  unFollowUser() {
    DatabaseServices.unFollowUser(
      widget.currentUserId,
      widget.userModell.id,
      activityid,
    );
    setState(() {
      _isFollowing = false;
    });
  }

  followUser() {
    DatabaseServices.followUser(
      widget.currentUserId,
      widget.userModell.id,
      activityid,
    );
    setState(() {
      _isFollowing = true;
    });
  }

  setupIsFollowing() async {
    bool isFollowingThisUser = await DatabaseServices.isFollowingUser(
      widget.currentUserId,
      widget.userModell.id,
    );
    setState(() {
      _isFollowing = isFollowingThisUser;
    });
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
            title: text(
              "دڵنیای لە شوێن نەکەوتنی ${widget.userModell.username}",
              whiteColor,
              18,
              FontWeight.normal,
              TextDirection.rtl,
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: text(
                  "نەخێر",
                  whiteColor.withOpacity(0.9),
                  18,
                  FontWeight.w500,
                  TextDirection.rtl,
                ),
              ),
              MaterialButton(
                onPressed: () {
                  unFollowUser();
                  Navigator.pop(context);
                },
                child: text(
                  "بەڵێ",
                  redolor.withOpacity(0.9),
                  18,
                  FontWeight.bold,
                  TextDirection.rtl,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    APi.getUserInfo(widget.postModel.userId);

    getMoviesWithRandomly();
    DatabaseServices.checkVersion(context);

    setState(() {
      numberOfSeries = widget.postModel.episode;
    });

    super.initState();
    setState(() {
      nextVideo = widget.postModel.video[0];
    });
    if (widget.isDirectLink == true) {
      //  Is Direct Uri
      if (widget.postModel.type == "Drama") {
        _controller = PodPlayerController(
          podPlayerConfig: const PodPlayerConfig(
            isLooping: false,
            forcedVideoFocus: true,
            autoPlay: true,
            videoQualityPriority: [720, 1080, 360],
          ),
          playVideoFrom: PlayVideoFrom.network(
            nextVideo,
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          ),
        )..initialise();
      } else {
        if (widget.isFromEpisode) {
          _controller = PodPlayerController(
            podPlayerConfig: const PodPlayerConfig(
              isLooping: false,
              forcedVideoFocus: true,
              autoPlay: true,
              videoQualityPriority: [720, 1080, 360],
            ),
            playVideoFrom: PlayVideoFrom.network(
              widget.episodeLink,
              videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
            ),
          )..initialise();
        } else {
          setState(() {
            nextVideo = widget.postModel.video[0];
          });

          _controller = PodPlayerController(
            podPlayerConfig: const PodPlayerConfig(
              isLooping: false,
              forcedVideoFocus: true,
              autoPlay: true,
              videoQualityPriority: [1080, 720, 360],
            ),
            playVideoFrom: PlayVideoFrom.network(nextVideo),
          )..initialise();
        }
      }
      /////////
    } else {
      // Is Viemo Uri
      if (widget.postModel.type == "Drama") {
        setState(() {
          nextVideo = widget.postModel.video[0];
        });

        _controller = PodPlayerController(
          podPlayerConfig: const PodPlayerConfig(
            isLooping: true,
            forcedVideoFocus: true,
            autoPlay: true,
            videoQualityPriority: [720, 1080, 360],
          ),
          playVideoFrom: PlayVideoFrom.vimeo(nextVideo),
        )..initialise();
      } else {
        if (widget.isFromEpisode) {
          _controller = PodPlayerController(
            podPlayerConfig: const PodPlayerConfig(
              isLooping: true,
              forcedVideoFocus: true,
              autoPlay: true,
              videoQualityPriority: [720, 1080, 360],
            ),
            playVideoFrom: PlayVideoFrom.vimeo(widget.episodeLink),
          )..initialise();
        } else {
          setState(() {
            nextVideo = widget.postModel.video[0];
          });

          _controller = PodPlayerController(
            podPlayerConfig: const PodPlayerConfig(
              isLooping: false,
              forcedVideoFocus: true,
              autoPlay: true,
              videoQualityPriority: [1080, 720, 360],
            ),
            playVideoFrom: PlayVideoFrom.vimeo(nextVideo),
          )..initialise();
        }
      }
    }
    if (widget.postModel.type == 'Drama') {
      getSeries();
    } else {
      print("isn't Drama");
    }
    setupIsFollowing();
    setupIsLikedPost();
    getLikesCount();
    Future.delayed(const Duration(minutes: 1), () {
      DatabaseServices.addView(widget.postModel, widget.currentUserId);
    });
    Future.delayed(const Duration(seconds: 1), () {
      DatabaseServices.setToHistory(
        widget.postModel,
        widget.currentUserId,
        widget.postModel.userId,
      );
    });
  }

  @override
  void dispose() {
    _controller!.dispose();

    super.dispose();
  }

  int numberOfSeries = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: appBarColor,
      appBar: AppBar(
        actions: [
          widget.postModel.type == 'Drama'
              ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    numberOfSeries.toString(),
                    style: GoogleFonts.barlow(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
              : const SizedBox(),
        ],
        backgroundColor: appBarColor.withOpacity(0.2),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text(widget.postModel.title),
        centerTitle: true,
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0, top: 1),
            child: PodVideoPlayer(
              backgroundColor: shadowColor,
              controller: _controller!,
              alwaysShowProgressBar: true,
              videoTitle: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  widget.postModel.title,
                  style: GoogleFonts.firaSans(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              videoThumbnail: DecorationImage(
                image: CachedNetworkImageProvider(widget.postModel.thumbnail),
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: shadowColor.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Like
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              widget.isAnonymous
                                  ? Fluttertoast.showToast(
                                    msg: 'پێویستە چونەژوورەوەت ئەنجام دابێت',
                                    backgroundColor: moviePageColor,
                                    textColor: whiteColor,
                                  )
                                  : likeOrUnlike();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: shadowColor.withOpacity(0.1),
                              ),
                              child: Icon(
                                _isLiked
                                    ? Icons.favorite_outlined
                                    : Icons.favorite_border,
                                color: _isLiked ? Colors.red : Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: AnimatedDigitWidget(
                              value: _likes,
                              valueColors: [
                                ValueColor(
                                  //When value <= 0 , the color changes to red
                                  condition: () => _likes != 0,
                                  color: Colors.white,
                                ),
                                // you can add more ...，but always take the last eligible.
                              ],
                              separateSymbol: "#",
                              enableSeparator: true,
                              duration: const Duration(milliseconds: 500),
                              textStyle: GoogleFonts.barlow(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Comment
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.bottomToTop,
                                  child: Comments(
                                    isAnonymous: widget.isAnonymous,
                                    currentUserId: widget.currentUserId,
                                    postModel: widget.postModel,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: shadowColor.withOpacity(0.1),
                              ),
                              child: const Icon(
                                CupertinoIcons.chat_bubble,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              widget.commentCount.toString(),
                              style: GoogleFonts.barlow(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Report
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: showReportModal,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: shadowColor.withOpacity(0.1),
                              ),
                              child: const Icon(
                                CupertinoIcons.info,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          text(
                            "ڕیپۆرت",
                            whiteColor,
                            14,
                            FontWeight.normal,
                            TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          widget.postModel.type == 'Drama'
              ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Episodes',
                      style: GoogleFonts.lato(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'See All',
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        // fontWeight: FontWeight.bold,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              )
              : const SizedBox(),
          // if video is drama part appear here
          if (widget.postModel.type != 'Drama')
            const SizedBox()
          else
            _otherEpisodes.isEmpty
                ? Padding(
                  padding: const EdgeInsets.only(top: 18.0, left: 8, right: 8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: shadowColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "هێشتاهیچ زنجیرەیەکی تربەردەست نیە",
                        style: GoogleFonts.barlow(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 4, left: 4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child:
                        _otherEpisodes == 0
                            ? const SizedBox()
                            : Row(
                              children: List.generate(_otherEpisodes.length, (
                                index,
                              ) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      nextVideo =
                                          _otherEpisodes[index].video[0];
                                      _controller!.changeVideo(
                                        playVideoFrom: PlayVideoFrom.vimeo(
                                          nextVideo,
                                        ),
                                      );
                                      getSeries();
                                      numberOfSeries =
                                          _otherEpisodes[index].episode;
                                      getLikesCount();
                                    });
                                  },
                                  child: OtherParts(
                                    numberOfSeries: numberOfSeries,
                                    currentUserId: widget.currentUserId,
                                    postModel: _otherEpisodes[index],
                                  ),
                                );
                              }),
                            ),
                  ),
                ),
          const SizedBox(height: 5),

          loadBanner
              ? SizedBox(
                child: UnityBannerAd(
                  placementId: androidbannerAds,
                  onLoad: (placementId) {
                    setState(() {
                      loadBanner = true;
                    });
                  },
                  onClick:
                      (placementId) => print('Banner clicked: $placementId'),
                  onFailed: (placementId, error, message) {
                    setState(() {
                      loadBanner = false;
                    });
                  },
                ),
              )
              : const SizedBox(),
          const SizedBox(height: 5),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recommendedMovies.length,
            itemBuilder: (BuildContext context, int index) {
              PostModel postModel = _recommendedMovies[index];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    APi.getUserInfo(postModel.userId);
                    // ignore: unrelated_type_equality_checks
                    widget.userModell == APi.vistitedUser;
                    _controller!.pause();
                  });
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: MoviePage(
                        currentUserId: APi.myid,
                        postModel: postModel,
                        userModell: APi.vistitedUser,
                      ),
                    ),
                  );
                },
                child: videoCard(postModel, context, widget.postModel.postuid),
              );
            },
          ),
        ],
      ),
    );
  }

  showReportModal() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.50,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 30, 29, 29),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(1),
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(
                                  255,
                                  78,
                                  89,
                                  123,
                                ).withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 2,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: widget.postModel.thumbnail,
                              fit: BoxFit.cover,
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            widget.postModel.title,
                            style: GoogleFonts.barlow(
                              color: whiteColor,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'تکایە جۆری کێشەکە دیاری بکە',
                          style: GoogleFonts.barlow(
                            color: whiteColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: whiteColor),
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 3),
                    child: buildItemsContainer(
                      Icons.wifi_2_bar_rounded,
                      "کێشەی خاوی ڤیدیۆ",
                      widget.postModel,
                      widget.currentUserId,
                      context,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 3, bottom: 3),
                    child: buildItemsContainer(
                      Icons.high_quality_outlined,
                      "خراپی کوالیتی ڤیدیۆ",
                      widget.postModel,
                      widget.currentUserId,
                      context,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 3, bottom: 3),
                    child: buildItemsContainer(
                      Icons.subtitles_outlined,
                      "کیشەی ژێرنووسی هەیە",
                      widget.postModel,
                      widget.currentUserId,
                      context,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 3, bottom: 3),
                    child: buildItemsContainer(
                      Icons.volume_down_rounded,
                      "کێشەی دەنگی هەیە",
                      widget.postModel,
                      widget.currentUserId,
                      context,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
