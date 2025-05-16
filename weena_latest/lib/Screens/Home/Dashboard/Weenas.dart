// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart';

import 'package:weena_latest/Screens/Home/Dashboard/Slider/slider.dart';
import 'package:weena_latest/Screens/Home/recommendedPost.dart';

import 'dashboard_utils.dart';

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
      tags.isEmpty ? buildShimmerTagList() : buildTagList(context, tags),
      const Divider(height: 1, thickness: 0.4, indent: 8, endIndent: 8),
      const SizedBox(height: 5),

      if (popularityMovies.isNotEmpty)
        buildMoviesHeader(context, "زۆرترین بینراو", popularityMovies),
      if (popularityMovies.isNotEmpty) const SizedBox(height: 3),
      if (popularityMovies.isEmpty)
        buildShimmerSlider()
      else
        BuildSlider(movies: popularityMovies, currentUserId: currentUserId),

      const SizedBox(height: 10),

      if (movies.isNotEmpty) buildMoviesHeader(context, "بۆ تۆ", movies),
      if (movies.isNotEmpty) const SizedBox(height: 3),
      movies.isEmpty
          ? buildShimmerMovieList()
          : _FadeInMovieList(movies: movies, currentUserId: currentUserId),
    ],
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
