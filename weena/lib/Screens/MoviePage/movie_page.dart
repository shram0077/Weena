import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emerge_alert_dialog/emerge_alert_dialog.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:timeago/timeago.dart' as timeago;
import "package:firebase_auth/firebase_auth.dart";
import 'package:palette_generator/palette_generator.dart';
import 'package:weena/Constant/Ads.dart';
import 'package:weena/Constant/constant.dart';
import 'package:weena/Models/Post.dart';
import 'package:weena/Models/SeriesModel.dart';
import 'package:weena/Models/userModel.dart';
import 'package:weena/Screens/MoviePage/Add_Episode.dart';
import 'package:weena/Screens/MoviePage/EditeDrama_s/EditDramas.dart';
import 'package:weena/Screens/MoviePage/MoviePageButtons.dart';
import 'package:weena/Screens/MoviePage/Series/ViewEpisodes.dart';
import 'package:weena/Screens/MoviePage/TrailerDialog.dart';
import 'package:weena/Screens/Search/search.dart';
import 'package:weena/Services/DatabaseServices.dart';
import 'package:weena/Widgets/widget.dart';

class MoviePage extends StatefulWidget {
  final PostModel postModel;
  final UserModell userModell;
  final String? currentUserId;
  const MoviePage(
      {super.key,
      required this.postModel,
      required this.userModell,
      this.currentUserId});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  bool isDirectLink = false;
  bool _isLiked = false;
  int _likes = 0;
  int _comments = 0;
  int _views = 0;
  getViewsCount() async {
    int viewsCount = await DatabaseServices.getViews(
      widget.postModel,
    );
    if (mounted) {
      setState(() {
        _views = viewsCount;
      });
    }
  }

  getCommentsCount() async {
    int commentsCount = await DatabaseServices.getCommentsCount(
      widget.postModel,
    );
    if (mounted) {
      setState(() {
        _comments = commentsCount;
      });
    }
  }

  getLikesCount() async {
    int likesCount = await DatabaseServices.getPostLikes(widget.postModel.id);
    if (mounted) {
      setState(() {
        _likes = likesCount;
      });
    }
  }

  setupIsLikedPost() async {
    bool isLikedThisPost = await DatabaseServices.isLikedPost(
      widget.postModel.id,
      widget.currentUserId!,
    );
    setState(() {
      _isLiked = isLikedThisPost;
    });
  }

  bool _isEpisodeEmpty = true;
  getEpisode() async {
    List<PostModel> otherEpisode =
        await DatabaseServices.getOtherEpisodes(widget.postModel);
    if (mounted) {
      if (otherEpisode.isEmpty) {
        print('Episode is empty');
        setState(() {
          _isEpisodeEmpty = false;
        });
      } else {
        print('Episode is not empty');
        _isEpisodeEmpty = true;
      }
    }
  }

  List<SeriesModel> _series = [];
  getSeries() async {
    List<SeriesModel> otherSeries =
        await DatabaseServices.getSeries(widget.postModel);
    if (mounted) {
      _series = otherSeries;
      print("SeriesList: ${_series.toList()}");
    }
  }

  PaletteGenerator? paletteGenerator;

  Future _genrateColors() async {
    paletteGenerator = await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(widget.postModel.thumbnail));
  }

  String admIMG =
      "https://firebasestorage.googleapis.com/v0/b/the-movies-and-drama.appspot.com/o/coverPicture%2FcoverPicture%2Fusers%2FuserCover_O0vj0b7RaYUi2UU4wAZ9ITqmWFE3.jpg?alt=media&token=e2090664-befa-474e-9344-898aa2405e74";
  String onClickLink = "";
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

  bool isMovieExists = false;
  setupIsMovieOnPlus18() async {
    bool x =
        await DatabaseServices.setupIsMovieOnPlus18(widget.postModel.postuid);
    setState(() {
      isMovieExists = x;
      print("is+18:$x");
    });
  }

  @override
  void initState() {
    if (widget.postModel.video.length > 9) {
      setState(() {
        isDirectLink = true;
      });
      print("isDirectLink $isDirectLink");
    } else {
      setState(() {
        isDirectLink = false;
        print("isDirectLink $isDirectLink");
      });
    }
    setupIsMovieOnPlus18();
    _genrateColors();
    setupIsLikedPost();
    getLikesCount();
    getViewsCount();
    getCommentsCount();
    DatabaseServices.checkVersion(context);
    super.initState();

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        if (isMovieExists) {
          setState(() {
            _showAlerMovie(context);
          });
        }
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await AdManager.loadUnityAd(placementId);
    });
    fetchAds();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchAds();
    });

    if (widget.postModel.type == 'Series') {
      getSeries();
    } else {
      print('is not series');
    }
  }

  bool user = FirebaseAuth.instance.currentUser!.isAnonymous;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBarColor,
      body: Stack(
        children: [
          Opacity(
              opacity: 0.5,
              child: CachedNetworkImage(
                imageUrl: widget.postModel.thumbnail,
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
              )),
          SingleChildScrollView(
            child: SafeArea(
                child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      widget.currentUserId != widget.postModel.userId
                          ? const SizedBox()
                          : widget.postModel.type != 'Drama'
                              ? popMenu()
                              : Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  type: PageTransitionType.fade,
                                                  child: EditDramas(
                                                    postID: widget
                                                        .postModel.postuid,
                                                    postModel: widget.postModel,
                                                    currentUserId:
                                                        widget.currentUserId!,
                                                  )));
                                        },
                                        icon: const Icon(
                                          FlutterIcons.edit_faw,
                                          color: Colors.white,
                                        )),
                                    _isEpisodeEmpty
                                        ? const SizedBox()
                                        : IconButton(
                                            onPressed: () {
                                              DatabaseServices.deletePost(
                                                  widget.postModel, context);
                                            },
                                            icon: const Icon(
                                              CupertinoIcons.trash,
                                              color: Colors.white,
                                            ))
                                  ],
                                ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                  spreadRadius: 0.5,
                                  blurRadius: 6,
                                  offset: const Offset(0.6, 1),
                                  color: paletteGenerator != null
                                      ? paletteGenerator!.vibrantColor != null
                                          ? paletteGenerator!
                                              .vibrantColor!.color
                                          : moviePageColor.withOpacity(0.4)
                                      : moviePageColor.withOpacity(0.4))
                            ], borderRadius: BorderRadius.circular(6)),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: CachedNetworkImage(
                                    // height: 240,
                                    width: 170,
                                    fit: BoxFit.cover,
                                    imageUrl: widget.postModel.thumbnail)),
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                                top: 5, bottom: 5, left: 3, right: 4.5),
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(7),
                                    topRight: Radius.circular(7)),
                                color: Color.fromARGB(255, 27, 26, 26)),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 3.0, right: 3),
                                  child: Container(
                                    width: 25,
                                    height: 22,
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(7),
                                            topRight: Radius.circular(7)),
                                        color: Color.fromARGB(255, 27, 26, 26),
                                        image: DecorationImage(
                                            image: AssetImage(
                                                'assets/images/imdb.png'))),
                                  ),
                                ),
                                Text(
                                  widget.postModel.imdbRating.toString(),
                                  style: GoogleFonts.barlow(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      widget.currentUserId == widget.postModel.userId
                          ? widget.postModel.type == "Drama"
                              ? GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.fade,
                                            child: AddEpisode(
                                              postModel: widget.postModel,
                                            )));
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 15, top: 65),
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                        color: moviePageColor,
                                        boxShadow: [
                                          BoxShadow(
                                              spreadRadius: 1,
                                              blurRadius: 9,
                                              color:
                                                  Colors.white.withOpacity(0.4))
                                        ],
                                        borderRadius:
                                            BorderRadius.circular(40)),
                                    child: const Center(
                                      child: Icon(
                                        CupertinoIcons.add_circled_solid,
                                        color: Colors.white,
                                        size: 35,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox()
                          : const SizedBox(),
                      widget.postModel.type != 'Series'
                          ? GestureDetector(
                              onTap: () async {
                                await AdManager.showVideoAd(
                                    context,
                                    user,
                                    widget.userModell,
                                    widget.postModel,
                                    widget.currentUserId,
                                    _comments,
                                    false,
                                    '',
                                    isDirectLink);
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.only(right: 15, top: 65),
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                    color: paletteGenerator != null
                                        ? paletteGenerator!.vibrantColor != null
                                            ? paletteGenerator!
                                                .vibrantColor!.color
                                            : moviePageColor
                                        : moviePageColor,
                                    boxShadow: [
                                      BoxShadow(
                                          spreadRadius: 1,
                                          blurRadius: 9,
                                          color:
                                              moviePageColor.withOpacity(0.4))
                                    ],
                                    borderRadius: BorderRadius.circular(40)),
                                child: const Center(
                                  child: Icon(
                                    CupertinoIcons.play_arrow_solid,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox()
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Material(
                        color: shadowColor.withOpacity(0.2),
                        elevation: 0,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          splashColor: paletteGenerator != null
                              ? paletteGenerator!.vibrantColor != null
                                  ? paletteGenerator!.vibrantColor!.color
                                  : moviePageColor
                              : moviePageColor,
                          onTap: () async {
                            await showDialog(
                                context: context,
                                builder: (_) => TrailerDialog(
                                      postModel: widget.postModel,
                                    ));
                          },
                          child: Container(
                            height: 45.0,
                            width: 115.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: <Widget>[
                                LayoutBuilder(builder: (context, constraints) {
                                  print(constraints);
                                  return Container(
                                    height: constraints.maxHeight,
                                    width: constraints.maxHeight,
                                    decoration: BoxDecoration(
                                      color: paletteGenerator != null
                                          ? paletteGenerator!.vibrantColor !=
                                                  null
                                              ? paletteGenerator!
                                                  .vibrantColor!.color
                                              : moviePageColor
                                          : moviePageColor,
                                      borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(0),
                                          bottomRight: Radius.circular(0),
                                          bottomLeft: Radius.circular(12),
                                          topLeft: Radius.circular(12)),
                                    ),
                                    child: const Icon(
                                      Icons.play_circle,
                                      color: Colors.white,
                                    ),
                                  );
                                }),
                                Expanded(
                                  child: Text(
                                    'ترەیلەر',
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.rtl,
                                    style: GoogleFonts.notoNaskhArabic(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                MoviePageButtons(
                  userModell: widget.userModell,
                  currentUserId: widget.currentUserId!,
                  postModel: widget.postModel,
                  viewsCount: _views,
                  isAnonymous: user,
                  commentsCount: _comments,
                  isMovieExists: isMovieExists,
                ),
                Padding(
                    padding: const EdgeInsets.only(
                        left: 4.0, right: 3, top: 8, bottom: 0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(widget.postModel.tags.length,
                            (index) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 4.0, right: 3),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        child: SearchSC(
                                          fromDashdboard: true,
                                          currentUserId: widget.currentUserId,
                                          fromDashdboardTags:
                                              widget.postModel.tags[index],
                                        )));
                              },
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 5, right: 5, top: 3, bottom: 3),
                                decoration: BoxDecoration(
                                  color: paletteGenerator != null
                                      ? paletteGenerator!.vibrantColor != null
                                          ? paletteGenerator!
                                              .vibrantColor!.color
                                          : shadowColor.withOpacity(0.2)
                                      : shadowColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.postModel.tags[index],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.5,
                                      fontFamily: 'Sirwan',
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    )),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: SelectableLinkify(
                              enableInteractiveSelection: true,
                              showCursor: true,
                              text: widget.postModel.title,
                              style: GoogleFonts.barlow(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 23,
                                  color: Colors.white),
                            ),
                          ),
                          Text(
                            timeago.format(widget.postModel.timestamp.toDate(),
                                locale: 'ku', allowFromNow: true),
                            style: const TextStyle(
                                color: Color.fromARGB(255, 215, 215, 215)),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      SelectableLinkify(
                        text: widget.postModel.type.tr,
                        style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'Sirwan'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SelectableLinkify(
                        text: widget.postModel.description,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 19,
                            color: Colors.white,
                            fontFamily: 'Sirwan'),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Color.fromARGB(44, 255, 255, 255),
                ),
                widget.postModel.type == 'Series'
                    ? StreamBuilder<QuerySnapshot>(
                        stream: postsRef
                            .doc(widget.userModell.id)
                            .collection('userPosts')
                            .doc(widget.postModel.id)
                            .collection('sessions')
                            .orderBy('session', descending: false)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return CircleProgressIndicator();
                          }
                          if (snapshot.hasData) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 5.0, right: 5, bottom: 10),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(
                                      snapshot.data!.docs.length, (index) {
                                    var sessionNumber =
                                        snapshot.data!.docs[index]['session'];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.fade,
                                                child: ViewEpisodes(
                                                  thumbnailColor: paletteGenerator !=
                                                          null
                                                      ? paletteGenerator!
                                                                  .vibrantColor !=
                                                              null
                                                          ? paletteGenerator!
                                                              .vibrantColor!
                                                              .color
                                                          : moviePageColor
                                                              .withOpacity(0.4)
                                                      : moviePageColor
                                                          .withOpacity(0.4),
                                                  commentCount: _comments,
                                                  user: user,
                                                  currentUserId:
                                                      widget.currentUserId!,
                                                  userModell: widget.userModell,
                                                  postModel: widget.postModel,
                                                  session: snapshot.data!
                                                      .docs[index]['session'],
                                                )));
                                        print(sessionNumber);
                                      },
                                      child: Column(
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 7, right: 7),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                              10,
                                                            ),
                                                            topLeft:
                                                                Radius.circular(
                                                                    10)),
                                                    child: CachedNetworkImage(
                                                      imageUrl: widget
                                                          .postModel.thumbnail,
                                                      width: 120,
                                                      height: 100,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: 120,
                                            height: 35,
                                            decoration: BoxDecoration(
                                                color: paletteGenerator != null
                                                    ? paletteGenerator!
                                                                .vibrantColor !=
                                                            null
                                                        ? paletteGenerator!
                                                            .vibrantColor!.color
                                                        : moviePageColor
                                                            .withOpacity(0.8)
                                                    : moviePageColor
                                                        .withOpacity(0.8),
                                                borderRadius: const BorderRadius
                                                    .only(
                                                    bottomLeft: Radius.circular(
                                                      10,
                                                    ),
                                                    bottomRight:
                                                        Radius.circular(10))),
                                            child: Center(
                                              child: Text(
                                                "وەرزی  ${sessionNumber.toString()}",
                                                textDirection:
                                                    TextDirection.rtl,
                                                style:
                                                    GoogleFonts.notoNaskhArabic(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 16),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            );
                          }
                          if (snapshot.data == null) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '.هێشتا هیچ وەرزێک دانەنراوە',
                                style: GoogleFonts.notoNaskhArabic(
                                    color: Colors.white, fontSize: 17),
                              ),
                            );
                          } else {
                            return Text(
                              "کێشەیەک هەیە",
                              style: GoogleFonts.barlow(color: Colors.white),
                            );
                          }
                        },
                      )
                    : const SizedBox(),
                // ignore: unnecessary_null_comparison
                admIMG != null
                    ? buildAds(admIMG, onClickLink)
                    : const SizedBox()
              ],
            )),
          )
        ],
      ),
    );
  }

  Future<void> _showAlerMovie(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return EmergeAlertDialog(
          alignment: Alignment.topCenter,
          emergeAlertDialogOptions: EmergeAlertDialogOptions(
              content: text(
                  "ئەم بەرهەمە چەند دیمەنێک لەخۆدەگرێت کەپێویستە کەسانی خوار ١٨ ساڵ بینەری نەبن.",
                  whiteColor,
                  18,
                  FontWeight.normal,
                  TextDirection.rtl),
              backgroundColor: const Color.fromARGB(255, 30, 28, 28),
              title: text("ئاگادارکەرەوە!", errorColor, 18, FontWeight.normal,
                  TextDirection.rtl),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: text("باشە", whiteColor, 18, FontWeight.normal,
                      TextDirection.rtl),
                ),
              ]),
        );
      },
    );
  }

  popMenu() {
    return PopupMenuButton<int>(
      icon: const Icon(
        Icons.more_vert,
        color: Colors.white,
      ),
      itemBuilder: (context) => [
        // popupmenu item 1
        PopupMenuItem(
          onTap: () {
            DatabaseServices.deletePost(widget.postModel, context);
          },
          value: 1,
          // row has two child icon and text.
          child: Row(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Icon(
                Icons.delete,
                color: Colors.white,
              ),
              const SizedBox(
                // sized box with width 10
                width: 10,
              ),
              Text(
                "Delete",
                style: GoogleFonts.barlow(color: Colors.white),
              )
            ],
          ),
        ),
      ],
      offset: const Offset(0, 100),
      color: const Color.fromARGB(117, 237, 233, 233),
      elevation: 2,
    );
  }
}
