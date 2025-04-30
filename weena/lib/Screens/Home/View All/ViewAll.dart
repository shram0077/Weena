import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:weena/Constant/constant.dart';
import 'package:weena/Screens/Home/View%20All/CardView.dart';
import 'package:weena/Screens/Search/search.dart';
import '../../../Widgets/widget.dart';

class ViewAllPost extends StatefulWidget {
  final String title;
  final List postModel;
  final String? currentuserId;
  const ViewAllPost(
      {super.key,
      required this.title,
      required this.postModel,
      this.currentuserId});
  @override
  State<ViewAllPost> createState() => _ViewAllPostState();
}

class _ViewAllPostState extends State<ViewAllPost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: appBarColor,
        appBar: AppBar(
          title: text(
              widget.title, whiteColor, 16, FontWeight.w500, TextDirection.rtl),
          centerTitle: true,
          backgroundColor: appBarColor,
          leading: backButton(context, 23),
          elevation: 0,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.topToBottom,
                          child: SearchSC(
                            currentUserId: widget.currentuserId,
                            fromDashdboard: true,
                          )));
                },
                icon: const Icon(
                  CupertinoIcons.search,
                  color: whiteColor,
                ))
          ],
        ),
        body: GridView.builder(
          itemCount: widget.postModel.length,
          itemBuilder: (context, index) => CardView(
            currentuserId: widget.currentuserId!,
            postModel: widget.postModel[index],
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, childAspectRatio: 1),
        ));
  }
}
