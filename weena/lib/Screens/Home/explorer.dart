import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:weena/Constant/constant.dart';
import 'package:weena/Models/Post.dart';
import 'package:weena/Models/userModel.dart';
import 'package:weena/Screens/MoviePage/movie_page.dart';
import 'package:weena/Widgets/widget.dart';

class Explorer extends StatefulWidget {
  final PostModel postModel;
  final String currentUserId;

  const Explorer(
      {super.key, required this.postModel, required this.currentUserId});
  @override
  State<Explorer> createState() => _ExplorerState();
}

class _ExplorerState extends State<Explorer> {
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
          return Container(
            padding: const EdgeInsets.all(10),
            width: 170,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.topToBottom,
                        child: MoviePage(
                          currentUserId: widget.currentUserId,
                          postModel: widget.postModel,
                          userModell: userModel,
                        )));
              },
              child: Column(
                children: <Widget>[
                  Container(
                    height: 190,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(
                              widget.postModel.thumbnail),
                        ),
                        color: moviePageColor.withOpacity(0.4)),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Flexible(
                    child: Text(
                      widget.postModel.title,
                      style: GoogleFonts.barlow(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.4,
                          color: appBarColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
