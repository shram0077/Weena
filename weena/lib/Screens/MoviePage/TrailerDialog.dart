import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pod_player/pod_player.dart';
import 'package:weena/Constant/constant.dart';
import 'package:weena/Models/Post.dart';

class TrailerDialog extends StatefulWidget {
  final PostModel postModel;

  const TrailerDialog({super.key, required this.postModel});

  @override
  State<TrailerDialog> createState() => _TrailerDialogState();
}

class _TrailerDialogState extends State<TrailerDialog> {
  PodPlayerController? _controller;
  @override
  void initState() {
    _controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.youtube(
        widget.postModel.trailer,
      ),
    )..initialise();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 250,
        height: 300,
        decoration: const BoxDecoration(color: Colors.transparent),
        child: PodVideoPlayer(
          frameAspectRatio: 16 / 9,
          backgroundColor: shadowColor,
          controller: _controller!,
          matchFrameAspectRatioToVideo: true,
          matchVideoAspectRatioToFrame: true,
          alwaysShowProgressBar: false,
          videoTitle: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              widget.postModel.title,
              style: GoogleFonts.firaSans(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold),
            ),
          ),
          videoThumbnail: DecorationImage(
            /// load from asset: AssetImage('asset_path')
            image: NetworkImage(
              widget.postModel.thumbnail,
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
