import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Models/Post.dart';
import 'package:weena_latest/Services/DatabaseServices.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentField extends StatefulWidget {
  final PostModel postModel;
  final String currentUserId;
  final bool isAnonymous;
  const CommentField(
      {Key? key,
      required this.postModel,
      required this.currentUserId,
      required this.isAnonymous})
      : super(key: key);
  @override
  State<CommentField> createState() => _CommentFieldState();
}

class _CommentFieldState extends State<CommentField> {
  final commentController = TextEditingController();

  FocusNode focusNode = FocusNode();
  bool emojiShowing = false;
  double _rating = 0.5;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.isAnonymous
            ? Fluttertoast.showToast(
                msg: 'پێویستە چونەژوورەوەت ئەنجام دابێت',
                backgroundColor: moviePageColor,
                textColor: whiteColor)
            : null;
      },
      child: Column(
        children: [
          _rating != 0.5
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.star_circle,
                        size: 25,
                        color: Colors.amber,
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      Text(
                        _rating.toString(),
                        style: GoogleFonts.barlow(color: Colors.amber),
                      )
                    ],
                  ),
                )
              : const SizedBox(),
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0, left: 3),
            child: SingleChildScrollView(
              primary: true,
              child: Container(
                height: 60,
                color: const Color.fromARGB(246, 7, 7, 7),
                // width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 3),
                          width: MediaQuery.of(context).size.width / 1.3,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: TextField(
                              textDirection: TextDirection.rtl,
                              enabled: widget.isAnonymous ? false : true,
                              onTap: () {
                                setState(() {
                                  emojiShowing = false;
                                });
                              },
                              onChanged: (value) {
                                setState(() {
                                  commentController;
                                });
                              },
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              focusNode: focusNode,
                              cursorColor: Colors.amber,
                              controller: commentController,
                              decoration: InputDecoration(
                                hintTextDirection: TextDirection.rtl,
                                border: InputBorder.none,
                                hintText: "لێدوانێک بنووسە...",
                                hintStyle: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        commentController.text.isEmpty
                            ? GestureDetector(
                                onTap: () {
                                  widget.isAnonymous
                                      ? Fluttertoast.showToast(
                                          msg:
                                              'پێویستە چونەژوورەوەت ئەنجام دابێت',
                                          backgroundColor: moviePageColor,
                                          textColor: whiteColor)
                                      : ratingDialog();
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: appBarColor,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      CupertinoIcons.star_circle,
                                      color: Colors.amber,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  submitComment();
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(right: 5),
                                  height: 40,
                                  width: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: moviePageColor,
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.solidPaperPlane,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  submitComment() {
    if (_rating == 0.5) {
      ratingDialog();
    } else {
      if (commentController.text.isEmpty) {
        Fluttertoast.showToast(
            msg: 'تێبینیەک بنووسە', backgroundColor: appcolor);
        Navigator.pop(context);
      } else {
        if (widget.postModel.userId == widget.currentUserId) {
          DatabaseServices.addComment(widget.postModel, widget.currentUserId,
              commentController.text, true, context, _rating);
        } else {
          DatabaseServices.addComment(widget.postModel, widget.currentUserId,
              commentController.text, false, context, _rating);
        }
      }
    }
  }

  void ratingDialog() {
    showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Center(
                child: Text(
                  'چەند نمرەی پێ دەدەی؟',
                  style: GoogleFonts.barlow(color: Colors.white),
                ),
              ),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RatingBar.builder(
                    initialRating: _rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _rating = rating;
                        print(_rating);
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  // ignore: sort_child_properties_last
                  child: Text(
                    'CANCEL'.tr,
                    style: GoogleFonts.barlow(color: Colors.white),
                  ),
                  onPressed: Navigator.of(context).pop,
                ),
                TextButton(
                  child: Text(
                    'زیادکردن',
                    style: GoogleFonts.barlow(color: Colors.white),
                  ),
                  onPressed: () {
                    if (_rating == 0.5) {
                      Fluttertoast.showToast(
                          msg: 'پیدانی نمرە نابێت کەمتر بێت لە ١');
                    } else {
                      submitComment();
                    }
                  },
                )
              ],
            )));
  }
}
