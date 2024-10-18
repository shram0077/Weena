import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weena/Constant/constant.dart';
import 'package:weena/Models/Post.dart';
import 'package:weena/Services/DatabaseServices.dart';
import 'package:weena/Widgets/widget.dart';

class EditDramas extends StatefulWidget {
  final PostModel postModel;
  final String currentUserId;
  final String postID;
  const EditDramas(
      {super.key,
      required this.postModel,
      required this.currentUserId,
      required this.postID});

  @override
  State<EditDramas> createState() => _EditDramasState();
}

class _EditDramasState extends State<EditDramas> {
  List<PostModel> _allDramas = [];
  bool _loading = false;
  String? postID;
  int numberOfEp = 0;

  getDramas() async {
    setState(() {
      _loading = true;
    });
    List<PostModel> otherSeries =
        await DatabaseServices.getOtherEpisodes(widget.postModel);
    if (mounted) {
      setState(() {
        _allDramas = otherSeries.toList();
      });
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    numberOfEp = widget.postModel.episode;

    getDramas();
  }

  Future<void> refreshDatas() async {
    await getDramas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: appBarColor,
        appBar: AppBar(
          backgroundColor: appBarColor,
          elevation: 0,
          title: text("دەستکاری کردنی دراماکان", Colors.white, 19,
              FontWeight.normal, TextDirection.rtl),
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: backButton(context, 23),
          actions: [
            _allDramas.length != 1
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                        onPressed: () {
                          removeEveryWhere();
                        },
                        child: text("سڕینەوە", Colors.red, 16,
                            FontWeight.normal, TextDirection.rtl)),
                  )
                : const SizedBox()
          ],
        ),
        body: _loading
            ? Center(
                child: CircleProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: refreshDatas,
                color: Colors.white,
                backgroundColor: moviePageColor,
                child: ListView(
                  children: [
                    GridView.builder(
                        shrinkWrap: true,
                        primary: false,
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                crossAxisCount: 2),
                        itemCount: _allDramas.length,
                        itemBuilder: (BuildContext context, int index) {
                          return detailCard(
                              _allDramas[index], _allDramas[index].episode);
                        })
                  ],
                ),
              ));
  }

  detailCard(
    PostModel postModel,
    int ep,
  ) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
          // ignore: prefer_const_literals_to_create_immutables
          boxShadow: [
            const BoxShadow(
              color: Color.fromARGB(255, 114, 114, 114),
              spreadRadius: 0.5,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
          image: DecorationImage(
              image: CachedNetworkImageProvider(
                widget.postModel.thumbnail,
              ),
              fit: BoxFit.cover),
          color: appcolor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(9)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
              padding: const EdgeInsets.only(left: 8, top: 3, bottom: 2),
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(9),
                      bottomLeft: Radius.circular(9)),
                  color: moviePageColor.withOpacity(0.9)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Episode $ep",
                    style: GoogleFonts.roboto(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                      onPressed: () {
                        deleteDrama(
                          postModel,
                        );
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ))
                ],
              )),
        ],
      ),
    );
  }

  deleteDrama(
    PostModel postModel,
  ) async {
    await postsRef
        .doc(widget.currentUserId)
        .collection("userPosts")
        .doc(widget.postID)
        .collection('otherEpisode')
        .doc(postModel.postuid)
        .delete()
        .whenComplete(() {
      setState(() {
        getDramas();
        Fluttertoast.showToast(
            msg: 'Deleted', backgroundColor: appcolor, textColor: Colors.white);
      });
    });
  }

  void removeEveryWhere() {
    showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              backgroundColor: Colors.grey[900],
              contentPadding: const EdgeInsets.all(10),
              title: Center(
                child: text(
                    "ئەم کردارە دراماکە دەسڕێتەوە لەهەموو شوێنێک، ئایادڵنیای؟",
                    Colors.white,
                    19,
                    FontWeight.normal,
                    TextDirection.rtl),
              ),
              actions: <Widget>[
                TextButton(
                  // ignore: sort_child_properties_last
                  child: Text(
                    'CANCEL'.tr,
                    style: GoogleFonts.barlow(color: Colors.white70),
                  ),
                  onPressed: Navigator.of(context).pop,
                ),
                TextButton(
                  child: Text(
                    'بەڵێ',
                    style: GoogleFonts.barlow(
                        color: Colors.red,
                        fontSize: 19,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    await postsRef
                        .doc(widget.currentUserId)
                        .collection("userPosts")
                        .doc(widget.postID)
                        .delete()
                        .whenComplete(() {
                      setState(() {
                        getDramas();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      });
                    });
                  },
                )
              ],
            )));
  }
}
