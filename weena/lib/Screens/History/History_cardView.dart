import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:weena/Constant/constant.dart';
import 'package:weena/Models/HistoryModel.dart';
import 'package:weena/Models/Post.dart';
import 'package:weena/Models/userModel.dart';
import 'package:weena/Screens/MoviePage/movie_page.dart';
import 'package:weena/Widgets/widget.dart';

class HistoryCardView extends StatefulWidget {
  final HistoryModel historyModel;
  final String currentUserId;
  const HistoryCardView({
    super.key,
    required this.historyModel,
    required this.currentUserId,
  });

  @override
  State<HistoryCardView> createState() => _CardViewState();
}

class _CardViewState extends State<HistoryCardView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: usersRef.doc(widget.historyModel.ownerId).get(),
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
          return FutureBuilder(
              future: newMoviesRef.doc(widget.historyModel.postuid).get(),
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
                        Text('Snapshot Error',
                            style: GoogleFonts.alef(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: errorColor)),
                      ],
                    ),
                  );
                }

                PostModel postModel = PostModel.fromDoc(snapshot.data);
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.fade,
                            child: MoviePage(
                              currentUserId: widget.currentUserId,
                              postModel: postModel,
                              userModell: userModel,
                            )));
                  },
                  child: Card(
                    color: Colors.transparent,
                    semanticContainer: false,
                    clipBehavior: Clip.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5,
                    margin: const EdgeInsets.all(10),
                    child: CachedNetworkImage(
                      imageUrl: postModel.thumbnail,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                );
              });
        });
  }
}
