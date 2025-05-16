import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:weena_latest/Models/Post.dart';

class BuildSlider extends StatefulWidget {
  final List movies;
  final String currentUserId;

  const BuildSlider({
    Key? key,
    required this.movies,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<BuildSlider> createState() => _BuildSliderState();
}

class _BuildSliderState extends State<BuildSlider> {
  late final PageController _controller;
  late Timer _autoPlayTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.7);

    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_controller.hasClients && widget.movies.isNotEmpty) {
        _currentPage = (_currentPage + 1) % widget.movies.length;
        _controller.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.movies.length,
        onPageChanged: (index) {
          _currentPage = index;
        },
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double value = 0;
              if (_controller.position.haveDimensions) {
                value = _controller.page! - index;
              } else {
                value = _currentPage - index.toDouble();
              }

              value = value.clamp(-1, 1);
              final scale = 1 - (value.abs() * 0.2);
              final rotationY = value * 0.5;

              return Transform(
                transform:
                    Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(rotationY)
                      ..scale(scale),
                alignment: Alignment.center,
                child: _buildCard(widget.movies[index]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCard(PostModel movie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: movie.thumbnail,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder:
                  (context, url) => Container(color: Colors.grey.shade300),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                color: Colors.black.withOpacity(0.4),
                child: Text(
                  movie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
