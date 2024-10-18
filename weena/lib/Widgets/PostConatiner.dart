import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weena/Constant/constant.dart';
import 'package:weena/Models/Post.dart';
import 'package:weena/Models/userModel.dart';
import 'package:weena/Screens/MoviePage/movie_page.dart';
import 'package:weena/Services/DatabaseServices.dart';

class PostConatiner extends StatefulWidget {
  final String currentUserId;
  final PostModel postModel;
  final UserModell userModell;

  const PostConatiner(
      {super.key,
      required this.currentUserId,
      required this.postModel,
      required this.userModell});

  @override
  State<PostConatiner> createState() => _PostConatinerState();
}

class _PostConatinerState extends State<PostConatiner> {
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
    getLikesCount();
    setupIsLikedPost();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.fade,
                child: MoviePage(
                  postModel: widget.postModel,
                  userModell: widget.userModell,
                  currentUserId: widget.currentUserId,
                )));
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(255, 59, 58, 58),
                spreadRadius: 0.5,
                blurRadius: 4,
                offset: Offset(0, 0.9),
              ),
            ],
            image: DecorationImage(
                image: CachedNetworkImageProvider(
                  widget.postModel.thumbnail,
                ),
                fit: BoxFit.cover),
            color: moviePageColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(9)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                  padding: const EdgeInsets.only(left: 8, top: 3, bottom: 2),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(9),
                          bottomLeft: Radius.circular(9)),
                      color: moviePageColor),
                  child: Text(
                    widget.postModel.title,
                    style: GoogleFonts.roboto(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  bool isloading = false;
  showPostBottom() {
    String postID = widget.postModel.postuid;
    String postTitle = widget.postModel.title;
    final thumbnailtRef =
        storageRef.child("thumbnail's/$postTitle, $postID.jpg");

    final videoRef = storageRef.child("video's/$postTitle, $postID.mp4");

    return showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            color: Colors.white,
            child: Wrap(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 5, bottom: 15),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          'Share',
                          style: GoogleFonts.roboto(),
                        ),
                        leading: const Icon(
                          CupertinoIcons.share,
                        ),
                      ),
                      ListTile(
                        onTap: () async {
                          try {
                            DatabaseServices.deletePost(
                                widget.postModel, context);
                            await thumbnailtRef.delete();
                            await videoRef.delete();
                          } catch (e) {
                            print(e);
                          }
                        },
                        title: Text(
                          'Delete',
                          style: GoogleFonts.roboto(color: Colors.red),
                        ),
                        leading: const Icon(
                          CupertinoIcons.trash,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
