import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:weena/Constant/constant.dart';
import 'package:weena/Models/Post.dart';
import 'package:weena/Models/userModel.dart';
import 'package:weena/Screens/MoviePage/movie_page.dart';
import 'package:weena/Widgets/widget.dart';

class FollowingPost extends StatefulWidget {
  final PostModel postModel;
  final String currentUserId;

  const FollowingPost(
      {super.key, required this.postModel, required this.currentUserId});

  @override
  State<FollowingPost> createState() => _FollowingPostState();
}

class _FollowingPostState extends State<FollowingPost> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: usersRef.doc(widget.postModel.userId).snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return loadingCard();
            // ignore: unrelated_type_equality_checks
          } else if (snapshot == ConnectionState.waiting) {
            return loadingCard();
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
          return Padding(
            padding: const EdgeInsets.only(left: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.bottomToTop,
                        child: MoviePage(
                          currentUserId: widget.currentUserId,
                          postModel: widget.postModel,
                          userModell: userModel,
                        )));
              },
              child: SizedBox(
                width: 130,
                height: 190,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: moviePageColor.withOpacity(0.4),
                          image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                  widget.postModel.thumbnail),
                              fit: BoxFit.cover),
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: double.maxFinite,
                        decoration: const BoxDecoration(
                            color: appcolor,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12))),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 0.0, left: 5),
                          child: Text(
                            widget.postModel.title,
                            // ignore: prefer_const_constructors
                            style: TextStyle(
                                fontSize: 14.5,
                                shadows: const <Shadow>[
                                  Shadow(
                                    offset: Offset(3.0, 3.0),
                                    blurRadius: 6.0,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ],
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
