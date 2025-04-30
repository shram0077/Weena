import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Models/CommentModel.dart';
import 'package:weena_latest/Models/Post.dart';
import 'package:weena_latest/Screens/MoviePage/Comment/buildComments.dart';
import 'package:weena_latest/Screens/MoviePage/Comment/commentField.dart';
import 'package:weena_latest/Services/DatabaseServices.dart';
import 'package:weena_latest/Widgets/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Comments extends StatefulWidget {
  final PostModel postModel;
  final String currentUserId;
  final bool isAnonymous;
  const Comments(
      {Key? key,
      required this.postModel,
      required this.currentUserId,
      required this.isAnonymous})
      : super(key: key);

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  final commentController = TextEditingController();

  bool emojiShowing = false;
  List<CommentModel> _comments = [];

  getComments() async {
    List<CommentModel> comments =
        await DatabaseServices.getComments(widget.postModel);
    if (mounted) {
      setState(() {
        _comments = comments.toList();
      });
      // ignore: avoid_print
      print(_comments.length);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBarColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 3,
        automaticallyImplyLeading: false,
        leading: backButton(context, 23),
        title: Text(
          'Comments'.tr,
          style: GoogleFonts.barlow(),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 7,
        ),
        child: Container(
          decoration: BoxDecoration(
              color: appBarColor.withOpacity(0.8),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: Column(
            children: [
              Expanded(
                child: _comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ignore: prefer_const_constructors
                            Icon(
                              CupertinoIcons.chat_bubble_2,
                              size: 55,
                              color: Colors.white,
                            ),
                            Text(
                              'No comments yet'.tr,
                              style: GoogleFonts.barlow(
                                  fontSize: 25,
                                  height: 1.5,
                                  color: whiteColor,
                                  fontWeight: FontWeight.w400),
                            )
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics()),
                            itemCount: _comments.length,
                            itemBuilder: (BuildContext context, int index) {
                              CommentModel commentModel = _comments[index];
                              return buildComments(
                                commentModel,
                                context,
                                widget.currentUserId,
                              );
                            }),
                      ),
              ),
              CommentField(
                isAnonymous: widget.isAnonymous,
                currentUserId: widget.currentUserId,
                postModel: widget.postModel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
