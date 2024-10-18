import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:weena/Constant/constant.dart';
import 'package:weena/Models/Post.dart';
import 'package:weena/Models/userModel.dart';
import 'package:weena/Screens/MoviePage/movie_page.dart';
import 'package:weena/Widgets/widget.dart';

class DramasPost extends StatefulWidget {
  final PostModel postModel;
  final String currentUserId;

  const DramasPost(
      {super.key, required this.postModel, required this.currentUserId});
  @override
  State<DramasPost> createState() => _DramasPostState();
}

class _DramasPostState extends State<DramasPost> {
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
          return GestureDetector(
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
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 3),
              child: Container(
                width: 250,
                height: 110,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        widget.postModel.thumbnail,
                      ),
                      fit: BoxFit.cover,
                    ),
                    color: moviePageColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          );
        });
  }
}
