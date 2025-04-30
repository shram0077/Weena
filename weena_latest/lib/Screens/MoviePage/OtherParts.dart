import 'package:cached_network_image/cached_network_image.dart';
import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Models/Post.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class OtherParts extends StatefulWidget {
  final PostModel postModel;
  final String currentUserId;
  final int numberOfSeries;
  const OtherParts(
      {Key? key,
      required this.postModel,
      required this.currentUserId,
      required this.numberOfSeries})
      : super(key: key);

  @override
  State<OtherParts> createState() => _OtherPartsState();
}

class _OtherPartsState extends State<OtherParts> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 7, right: 7),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(
                        10,
                      ),
                      topLeft: Radius.circular(10)),
                  child: CachedNetworkImage(
                    imageUrl: widget.postModel.thumbnail,
                    width: 120,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 120,
          height: 35,
          decoration: BoxDecoration(
              color: widget.postModel.episode != widget.numberOfSeries
                  ? shadowColor.withOpacity(0.5)
                  : moviePageColor.withOpacity(0.8),
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(
                    10,
                  ),
                  bottomRight: Radius.circular(10))),
          child: Center(
            child: Text(
              "Episode ${widget.postModel.episode.toString()}",
              style: GoogleFonts.barlow(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16),
            ),
          ),
        )
      ],
    );
  }
}
