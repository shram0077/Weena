import 'package:cached_network_image/cached_network_image.dart';
import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Models/userModel.dart';
import 'package:weena_latest/Models/Post.dart';
import 'package:weena_latest/Screens/MoviePage/movie_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shimmer/shimmer.dart';

class Recommended extends StatefulWidget {
  final PostModel postModel;
  final String currentUserId;

  const Recommended({
    Key? key,
    required this.postModel,
    required this.currentUserId,
  }) : super(key: key);
  @override
  State<Recommended> createState() => _RecommendedState();
}

class _RecommendedState extends State<Recommended> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: usersRef.doc(widget.postModel.userId).snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData ||
            snapshot.connectionState == ConnectionState.waiting) {
          return _loadingCard();
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Snapshot Error',
                  style: GoogleFonts.alef(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: errorColor,
                  ),
                ),
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
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 2),
            child: Container(
              width: 135,
              height: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(widget.postModel.thumbnail),
                  fit: BoxFit.cover,
                ),
                color: moviePageColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _loadingCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: 120,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
