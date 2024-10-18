import 'package:animated_digit/animated_digit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weena/Services/DatabaseServices.dart';

class LikeButton extends StatefulWidget {
  final String currentUserId;
  final String ownerId;
  final String postId;
  final List pictures;
  final String profilePicture;
  const LikeButton({
    super.key,
    required this.currentUserId,
    required this.ownerId,
    required this.postId,
    required this.pictures,
    required this.profilePicture,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      duration: const Duration(milliseconds: 200), vsync: this, value: 1.0);

  bool _isFavorite = false;
  bool isAnonymous = FirebaseAuth.instance.currentUser!.isAnonymous;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  int _likes = 0;
  getLikesCount() async {
    int likesCount = await DatabaseServices.getPostLikes(widget.postId);
    if (mounted) {
      setState(() {
        _likes = likesCount;
      });
    }
  }

  likePost() {
    DatabaseServices.likePost(
        widget.postId,
        widget.ownerId,
        widget.currentUserId,
        widget.pictures.isNotEmpty ? widget.pictures[0] : "",
        true);
    setState(() {
      _isFavorite = true;
      _likes++;
    });
  }

  unLikePost() {
    DatabaseServices.unlikePost(widget.postId, widget.ownerId,
        widget.currentUserId, widget.postId, true);
    setState(() {
      _isFavorite = false;
      _likes--;
    });
  }

  likeOrUnlike() {
    if (_isFavorite) {
      unLikePost();
    } else {
      likePost();
    }
  }

  setupIsLikedPost() async {
    bool isLikedThisPost = await DatabaseServices.isLikedPost(
      widget.postId,
      widget.currentUserId,
    );
    setState(() {
      _isFavorite = isLikedThisPost;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLikesCount();
    setupIsLikedPost();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (isAnonymous) {
            } else {
              setState(() {
                likeOrUnlike();
              });
              _controller.reverse().then((value) => _controller.forward());
            }
          },
          child: ScaleTransition(
            scale: Tween(begin: 0.7, end: 1.0).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
            child: _isFavorite
                ? const Icon(
                    Icons.favorite,
                    size: 25,
                    color: Colors.red,
                  )
                : Icon(
                    Icons.favorite_border,
                    size: 25,
                    color: isAnonymous ? Colors.grey.shade700 : Colors.grey,
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: AnimatedDigitWidget(
            value: _likes,
            duration: const Duration(milliseconds: 500),
            textStyle: GoogleFonts.barlow(color: Colors.grey),
          ),
        )
      ],
    );
  }
}
