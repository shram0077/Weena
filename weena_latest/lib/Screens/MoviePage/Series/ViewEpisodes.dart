import 'package:cached_network_image/cached_network_image.dart';
import 'package:weena_latest/Constant/Ads.dart';
import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Models/Post.dart';
import 'package:weena_latest/Models/userModel.dart';
import 'package:weena_latest/Widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewEpisodes extends StatefulWidget {
  final PostModel postModel;
  final String session;
  final UserModell userModell;
  final String currentUserId;
  final bool user;
  final int commentCount;
  final Color thumbnailColor;
  const ViewEpisodes(
      {Key? key,
      required this.postModel,
      required this.session,
      required this.userModell,
      required this.currentUserId,
      required this.user,
      required this.commentCount,
      required this.thumbnailColor})
      : super(key: key);

  @override
  State<ViewEpisodes> createState() => _ViewEpisodesState();
}

class _ViewEpisodesState extends State<ViewEpisodes> {
  bool isYoutubeLink = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.postModel.video.length > 9) {
      setState(() {
        isYoutubeLink = true;
      });
    } else {
      setState(() {
        isYoutubeLink = false;
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await AdManager.loadUnityAd(placementId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBarColor,
      appBar: AppBar(
        title: Text(
          "${widget.postModel.title}-S${widget.session}",
          style: GoogleFonts.lato(
              color: Colors.white, fontWeight: FontWeight.w500, wordSpacing: 1),
        ),
        centerTitle: true,
        backgroundColor: widget.thumbnailColor,
        leading: backButton(context, 23),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: postsRef
              .doc(widget.postModel.userId)
              .collection('userPosts')
              .doc(widget.postModel.id)
              .collection('sessions')
              .doc(widget.session)
              .collection('Videos')
              .orderBy('episode', descending: false)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext ctx, index) {
                    var thumbnail = snapshot.data!.docs[index]['thumbnail'];
                    var episode = snapshot.data!.docs[index]['episode'];
                    var episodeLink = snapshot.data!.docs[index]['video'];
                    return GestureDetector(
                      onTap: () {
                        AdManager.showVideoAd(
                            ctx,
                            widget.user,
                            widget.userModell,
                            widget.postModel,
                            widget.currentUserId,
                            widget.commentCount,
                            true,
                            episodeLink,
                            isYoutubeLink);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            // ignore: prefer_const_literals_to_create_immutables
                            boxShadow: [
                              const BoxShadow(
                                color: Color.fromARGB(255, 59, 58, 58),
                                spreadRadius: 0.5,
                                blurRadius: 4,
                                offset: Offset(0, 0.9),
                              ),
                            ],
                            image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                  thumbnail,
                                ),
                                fit: BoxFit.cover),
                            color: widget.thumbnailColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(9)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 8, top: 3, bottom: 2),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                      bottomRight: Radius.circular(9),
                                      bottomLeft: Radius.circular(9)),
                                  color: widget.thumbnailColor),
                              child: Center(
                                child: Text(
                                  "ئەڵقەی  $episode",
                                  style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
            }
            return Center(
              child: CircleProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
