import 'package:animated_digit/animated_digit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weena/Services/DatabaseServices.dart';

class ReFeedButton extends StatefulWidget {
  final int refeedCount;
  final String currentUserId;
  final String ownerId;
  final String postId;
  final List pictures;
  final String profilePicture;
  const ReFeedButton(
      {super.key,
      required this.refeedCount,
      required this.currentUserId,
      required this.ownerId,
      required this.postId,
      required this.pictures,
      required this.profilePicture});
  @override
  State<ReFeedButton> createState() => _ReFeedButtonState();
}

class _ReFeedButtonState extends State<ReFeedButton> {
  int _reeFeedCount = 0;
  bool _isReefeded = false;
  bool isAnonymous = FirebaseAuth.instance.currentUser!.isAnonymous;

  getReefedsCount() async {
    int likesCount = await DatabaseServices.getReedesCount(widget.postId);
    if (mounted) {
      setState(() {
        _reeFeedCount = likesCount;
      });
    }
  }

  reefeed() {
    DatabaseServices.reefeed(
        widget.postId,
        widget.ownerId,
        widget.currentUserId,
        widget.pictures.isNotEmpty ? widget.pictures[0] : "",
        true);
    setState(() {
      _isReefeded = true;
      _reeFeedCount++;
    });
  }

  unReefeed() {
    DatabaseServices.unreefeed(widget.postId, widget.ownerId,
        widget.currentUserId, widget.postId, true);
    setState(() {
      _isReefeded = false;
      _reeFeedCount--;
    });
  }

  reefedORunReefeed() {
    if (_isReefeded) {
      unReefeed();
    } else {
      reefeed();
    }
  }

  setupIsReefeed() async {
    bool isLikedThisPost = await DatabaseServices.isReefeded(
      widget.postId,
      widget.currentUserId,
    );
    setState(() {
      _isReefeded = isLikedThisPost;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupIsReefeed();
    getReefedsCount();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        InkWell(
          onTap: () {
            if (isAnonymous) {
            } else {
              reefedORunReefeed();
            }
          },
          borderRadius: BorderRadius.circular(15),
          child: Icon(
            FlutterIcons.retweet_ant,
            color: _isReefeded ? Colors.green : Colors.grey,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: AnimatedDigitWidget(
            value: _reeFeedCount,
            duration: const Duration(milliseconds: 500),
            textStyle: GoogleFonts.barlow(color: Colors.grey),
          ),
        )
      ],
    );
  }
}
