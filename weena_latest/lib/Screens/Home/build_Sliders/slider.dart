import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Screens/Home/build_Sliders/newsPage.dart';
import 'package:weena_latest/Widgets/widget.dart';

class BuildSlider extends StatelessWidget {
  const BuildSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: newsRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircleProgressIndicator());
        }
        if (!snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.only(top: 300.0),
            child: Center(child: CircleProgressIndicator()),
          );
          // ignore: unrelated_type_equality_checks
        } else if (snapshot == ConnectionState.waiting) {
          return Center(child: CircleProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("کێشەیەک هەیە!",
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.alef(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: errorColor)),
              ],
            ),
          );
        }

        List<DocumentSnapshot> documents = snapshot.data!.docs;
        return CarouselSlider.builder(
          itemCount: documents.length,
          options: CarouselOptions(
            viewportFraction: 0.8,
            autoPlayCurve: Curves.ease,
            height: 180.0,
            pauseAutoPlayInFiniteScroll: false,
            enlargeCenterPage: true,
            autoPlay: true,
            aspectRatio: 16 / 9,
            autoPlayAnimationDuration: const Duration(seconds: 1),
            onPageChanged: (index, reason) {
              documents[index].data();
            },
          ),
          itemBuilder: (context, index, realIndex) {
            DocumentSnapshot document = documents[index];
            // Extract data from the document
            String title = document['newsTitle'];
            String imageURL = document['picture'];
            String description = document['description'];
            String byUserId = document['byUserId'];
            Timestamp timestamp = document['timestamp'];
            dynamic views = document["views"];
            String newsID = document["newsID"];
            // Build the CarouselSlider item
            return buildUICARD(title, imageURL, description, context, byUserId,
                timestamp, views, newsID);
          },
        );
      },
    );
  }

  Widget buildUICARD(
      String newsTitle,
      String imageURL,
      String description,
      context,
      String byUserId,
      Timestamp timestamp,
      dynamic views,
      String newsID) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.fade,
                child: NewsPage(
                    byUserId: byUserId,
                    description: description,
                    newsTitle: newsTitle,
                    picture: imageURL,
                    timestamp: timestamp,
                    views: views,
                    newsID: newsID)));
      },
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: moviePageColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8.0),
          image: DecorationImage(
            image: CachedNetworkImageProvider(imageURL),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
