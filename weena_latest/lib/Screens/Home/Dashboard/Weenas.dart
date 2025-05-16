// ignore_for_file: unnecessary_import

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shimmer/shimmer.dart';
import 'package:weena_latest/APi/apis.dart';
import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Screens/Home/Dashboard/Slider/slider.dart';
import 'package:weena_latest/Screens/Home/View%20All/ViewAll.dart';
import 'package:weena_latest/Screens/Home/recommendedPost.dart';
import 'package:weena_latest/Screens/Search/search.dart';
import 'package:weena_latest/Widgets/widget.dart';

Widget buildWeenas(
  BuildContext context,
  List tags,
  List movies,
  List popularityMovies,
  String currentUserId,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 8),
      tags.isEmpty ? _buildShimmerTagList() : _buildTagList(context, tags),
      const Divider(height: 1, thickness: 0.4, indent: 8, endIndent: 8),
      const SizedBox(height: 5),

      if (popularityMovies.isNotEmpty)
        _buildMoviesHeader(context, "زۆرترین بینراو", popularityMovies),
      if (popularityMovies.isNotEmpty) const SizedBox(height: 3),
      if (popularityMovies.isEmpty)
        _buildShimmerMovieList()
      else
        BuildSlider(movies: popularityMovies, currentUserId: currentUserId),

      const SizedBox(height: 10),

      if (movies.isNotEmpty) _buildMoviesHeader(context, "بۆ تۆ", movies),
      if (movies.isNotEmpty) const SizedBox(height: 3),
      movies.isEmpty
          ? _buildShimmerMovieList()
          : _FadeInMovieList(movies: movies, currentUserId: currentUserId),
    ],
  );
}

Widget _buildMoviesHeader(BuildContext context, String headertxt, List posts) {
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
            appBarColor.withOpacity(0.8),
            11.5,
            FontWeight.normal,
            TextDirection.rtl,
          ),
        ),
        text(
          headertxt,
          appBarColor.withOpacity(0.9),
          15.5,
          FontWeight.normal,
          TextDirection.rtl,
        ),
      ],
    ),
  );
}

Widget _buildTagList(BuildContext context, List tags) {
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

Widget _buildShimmerTagList() {
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

class _FadeInMovieList extends StatefulWidget {
  final List movies;
  final String currentUserId;

  const _FadeInMovieList({
    Key? key,
    required this.movies,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<_FadeInMovieList> createState() => _FadeInMovieListState();
}

class _FadeInMovieListState extends State<_FadeInMovieList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 9),
          scrollDirection: Axis.horizontal,
          itemCount: widget.movies.length,
          separatorBuilder: (_, __) => const SizedBox(width: 9),
          itemBuilder: (context, index) {
            final movie = widget.movies[index];
            return Recommended(
              key: ValueKey(movie.id ?? index),
              currentUserId: widget.currentUserId,
              postModel: movie,
            );
          },
        ),
      ),
    );
  }
}

Widget _buildShimmerMovieList() {
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
