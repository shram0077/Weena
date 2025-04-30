import 'package:cached_network_image/cached_network_image.dart';
import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Models/Post.dart';
import 'package:weena_latest/Models/userModel.dart';
import 'package:weena_latest/Screens/Profile/profile.dart';
import 'package:weena_latest/Services/DatabaseServices.dart';
import 'package:weena_latest/encryption_decryption/encryption.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class MoviePageButtons extends StatefulWidget {
  final UserModell userModell;
  final PostModel postModel;
  final String currentUserId;
  final viewsCount;
  final commentsCount;
  final bool isAnonymous;
  final bool isMovieExists;
  const MoviePageButtons(
      {Key? key,
      required this.userModell,
      required this.postModel,
      required this.currentUserId,
      this.viewsCount,
      required this.isAnonymous,
      this.commentsCount,
      required this.isMovieExists})
      : super(key: key);
  @override
  State<MoviePageButtons> createState() => _MoviePageButtonsState();
}

class _MoviePageButtonsState extends State<MoviePageButtons> {
  bool _isLiked = false;
  int _likes = 0;
  var key;
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
    DatabaseServices.unlikePost(widget.postModel.id, widget.postModel.userId,
        widget.currentUserId, widget.postModel.id, false);
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupIsLikedPost();
    getLikesCount();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(8),
          width: 60,
          decoration: BoxDecoration(
              color: shadowColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(
                Icons.favorite_border,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                _likes.toString(),
                style: GoogleFonts.barlow(
                    color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Container(
          padding: const EdgeInsets.all(8),
          width: 60,
          decoration: BoxDecoration(
              color: shadowColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.chat_bubble_text,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                widget.commentsCount.toString(),
                style: GoogleFonts.barlow(
                    color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Container(
          padding: const EdgeInsets.all(8),
          width: 60,
          decoration: BoxDecoration(
              color: shadowColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.eye,
                color: Colors.white,
                size: 19,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                widget.viewsCount.toString(),
                textAlign: TextAlign.end,
                style: GoogleFonts.barlow(
                    color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        widget.isMovieExists
            ? SizedBox(
                width: 10,
              )
            : SizedBox(),
        widget.isMovieExists
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 204, 21, 8),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.person_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      "+18",
                      textAlign: TextAlign.end,
                      style: GoogleFonts.barlow(
                          color: whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            : SizedBox(),
        const Spacer(),
        InkWell(
          borderRadius: BorderRadius.circular(6),
          splashColor: shadowColor.withOpacity(0.2),
          onTap: () {
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.topToBottom,
                    child: ProfileScreen(
                      userModel: widget.userModell,
                      visitedUserId: widget.postModel.userId,
                      currentUserId: widget.currentUserId,
                    )));
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(23),
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                          MyEncriptionDecription.decryptWithAESKey(
                              widget.userModell.profilePicture)),
                      fit: BoxFit.cover,
                      opacity: 35,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFF292b37)),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                widget.userModell.name,
                style: GoogleFonts.barlow(
                    color: Colors.white, fontWeight: FontWeight.w500),
              )
            ],
          ),
        ),
      ]),
    );
  }
}
