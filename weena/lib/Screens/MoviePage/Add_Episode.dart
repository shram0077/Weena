import 'dart:io';
import 'package:flutter/services.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:weena/Models/Post.dart';
import 'package:weena/Services/DatabaseServices.dart';
import 'package:weena/Widgets/widget.dart';
import '../../Constant/constant.dart';

class AddEpisode extends StatefulWidget {
  final PostModel postModel;

  const AddEpisode({super.key, required this.postModel});

  @override
  State<AddEpisode> createState() => _AddEpisodeState();
}

class _AddEpisodeState extends State<AddEpisode> {
  bool _loading = false;
  bool? isPlay;
  File? _video;
  final videoURLController = TextEditingController();
  String? _videoURL;

  dynamic lastEpisode;
  getSeries() async {
    List<PostModel> otherSeries =
        await DatabaseServices.getOtherEpisodes(widget.postModel);
    if (mounted) {
      setState(() {
        if (otherSeries.isEmpty) {
          print('NO HAVE ANY SERIES');
          setState(() {
            lastEpisode = 2;
          });
        } else {
          lastEpisode = otherSeries.last.episode;
          setState(() {
            lastEpisode++;
            _loading = false;
          });
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSeries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBarColor,
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Adding other episode to ${widget.postModel.title}",
            style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          backgroundColor: appBarColor,
          automaticallyImplyLeading: false,
          leading: _loading ? const SizedBox() : backButton(context, 25)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: TextFormField(
                  textDirection: TextDirection.ltr,
                  style: GoogleFonts.barlow(),
                  controller: videoURLController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Video URL',
                  ),
                  onChanged: (value) {
                    _videoURL = value;
                    setState(() {
                      videoURLController;
                      _video;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Episode:',
                  style: GoogleFonts.lato(
                      fontSize: 15.5,
                      color: whiteColor,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  lastEpisode.toString(),
                  style: GoogleFonts.lato(
                    color: whiteColor,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            _loading
                ? CircleProgressIndicator()
                : SizedBox(
                    height: 50,
                    width: 120,
                    child: MaterialButton(
                      splashColor: const Color.fromARGB(0, 255, 214, 64),
                      onPressed: () {
                        if (videoURLController.text.isEmpty) {
                          Clipboard.getData(Clipboard.kTextPlain).then((value) {
                            videoURLController.text = videoURLController.text +
                                value!.text.toString();
                            setState(() {
                              videoURLController.text;
                              _video;
                            });
                          });
                        } else {
                          if (_loading) {
                            Fluttertoast.showToast(msg: 'in process');
                          } else {
                            addOtherseries(widget.postModel);
                          }
                        }
                      },
                      color: moviePageColor,
                      padding: const EdgeInsets.all(15),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        videoURLController.text.isEmpty ? "Paste" : "Add",
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

// abe if else lera danem agar znjera ayksnabu ba znjeray zyadkraw nabe rubdat krdaraka
  addOtherseries(PostModel postModel) async {
    setState(() {
      _loading = true;
    });
    var uuid = const Uuid().v4();
    await postsRef
        .doc(widget.postModel.userId)
        .collection('userPosts')
        .doc(widget.postModel.postuid)
        .collection('otherEpisode')
        .doc(uuid)
        .set({
      "description": widget.postModel.description,
      "video": _videoURL,
      "Timestamp": Timestamp.now(),
      "postuid": uuid,
      "title": widget.postModel.title,
      "type": widget.postModel.type,
      "verified": false,
      "userId": widget.postModel.userId,
      'thumbnail': widget.postModel.thumbnail,
      "episode": lastEpisode,
      "series": 0,
      'tags': widget.postModel.tags,
      "trailer": widget.postModel.trailer,
      "imdbRating": widget.postModel.imdbRating,
      "likes": widget.postModel.likes,
      "views": widget.postModel.views
    });
    setState(() {
      _loading = false;
    });
    print("Data's uploaded to Cloud Firestore");
    Fluttertoast.showToast(
        msg: 'Added', backgroundColor: moviePageColor, textColor: Colors.white);
    Navigator.pop(context);
  }
}
