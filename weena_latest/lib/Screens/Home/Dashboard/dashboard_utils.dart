import "dart:math";

import "package:flutter/material.dart";
import "package:page_transition/page_transition.dart";
import "package:shimmer/shimmer.dart";
import "package:weena_latest/APi/apis.dart";
import "package:weena_latest/Constant/constant.dart";
import "package:weena_latest/Screens/Home/View%20All/ViewAll.dart";
import "package:weena_latest/Screens/Search/search.dart";
import "package:weena_latest/Widgets/widget.dart";

Widget buildMoviesHeader(BuildContext context, String headertxt, List posts) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.bottomToTop,
                child: ViewAllPost(
                  postModel: posts,
                  currentuserId: APi.myid,
                  title: headertxt,
                ),
              ),
            );
          },
          child: text(
            "View All",
            whiteColor.withOpacity(0.8),
            11.5,
            FontWeight.normal,
            TextDirection.rtl,
          ),
        ),
        text(
          headertxt,
          whiteColor.withOpacity(0.9),
          15.5,
          FontWeight.normal,
          TextDirection.rtl,
        ),
      ],
    ),
  );
}

Widget buildTagList(BuildContext context, List tags) {
  final random = Random();
  final shuffledTags = List.of(tags)..shuffle(random); // Create a shuffled copy

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    physics: const BouncingScrollPhysics(),
    child: Row(
      textDirection: TextDirection.rtl,
      children: List.generate(shuffledTags.length, (index) {
        final tag = shuffledTags[index];
        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: SearchSC(
                    fromDashdboard: true,
                    currentUserId: APi.myid,
                    fromDashdboardTags: tag,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: moviePageColor,
              ),
              child: text(
                tag,
                whiteColor,
                13,
                FontWeight.w500,
                TextDirection.rtl,
              ),
            ),
          ),
        );
      }),
    ),
  );
}

Widget buildShimmerTagList() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    physics: const BouncingScrollPhysics(),
    child: Row(
      children: List.generate(6, (index) {
        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 30,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300],
              ),
            ),
          ),
        );
      }),
    ),
  );
}

Widget buildShimmerSlider() {
  return SizedBox(
    height: 200,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 9),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder:
          (context, index) => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: 300,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
    ),
  );
}

Widget buildShimmerMovieList() {
  return SizedBox(
    height: 220,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 9),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, index) => shimmerMovieCard(),
    ),
  );
}

Widget shimmerMovieCard() {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      width: 140,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(9),
      ),
    ),
  );
}
