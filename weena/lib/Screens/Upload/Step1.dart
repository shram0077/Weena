import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pod_player/pod_player.dart';
import 'package:video_url_validator/video_url_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import "package:firebase_auth/firebase_auth.dart";
import 'package:weena/Constant/constant.dart';
import 'package:weena/Models/userModel.dart';
import 'package:weena/Screens/Upload/Step2.dart';
import 'package:weena/Widgets/widget.dart';

import '../../Models/ActivityModel.dart';

class Step1 extends StatefulWidget {
  final String currentUserId;

  const Step1({
    super.key,
    required this.currentUserId,
  });
  @override
  State<Step1> createState() => _Step1State();
}

class _Step1State extends State<Step1> {
  bool user = FirebaseAuth.instance.currentUser!.isAnonymous;
  File? _video;
  File? thumbnailPic;
  PodPlayerController? _controller;
  String? _trailer;
  final TextEditingController _trailerController = TextEditingController();

  final picker = ImagePicker();
  final bool _isLoading = false;
  bool? isPlay;
  _pickVideo() async {
    XFile? pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile == null) {
      print('Failed to Repicked file');
    } else {
      _video = File(pickedFile.path);
      _controller = PodPlayerController(
        playVideoFrom: PlayVideoFrom.file(
          _video!,
        ),
      )..initialise();
      var asR = _controller!.videoPlayerValue!.aspectRatio;
      print("AspectRatio of The Video $asR");
    }
  }

  // Pick Cover picture
  pickThumbnail() async {
    final XFile? thmb = await picker.pickImage(source: ImageSource.gallery);
    if (thmb == null) {
      print('Error');
    } else {
      setState(() {
        thumbnailPic = File(thmb.path);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  UserModell? userModell;
  ActivityModel? activityModel;

  var validator = VideoURLValidator();
  var youtubelinkValidate;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: appBarColor,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: appBarColor,
          title: text("هەنگاوی یەکەم", whiteColor, 18, FontWeight.normal,
              TextDirection.rtl),
          leading: backButton(context, 23),
          automaticallyImplyLeading: false,
          actions: [
            user
                ? const SizedBox()
                : CupertinoButton(
                    // ignore: sort_child_properties_last
                    child: text(_video == null ? "" : 'دواتر', errorColor, 19,
                        FontWeight.normal, TextDirection.rtl),
                    onPressed: () {
                      if (youtubelinkValidate != true) {
                        Fluttertoast.showToast(
                            msg: "تکایە دڵنیابەرەوە لە ترایلەرەکەت",
                            backgroundColor: moviePageColor);
                      } else {
                        _video != null
                            ? Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.fade,
                                    child: Step2(
                                      currentUserId: widget.currentUserId,
                                      video: _video!,
                                      thumbnailPic: thumbnailPic!,
                                      trailer: _trailer!,
                                    )))
                            : null;
                      }
                    })
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: user
              ? Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.person,
                        size: 65,
                        color: appcolor,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "You must be sign in or sign up",
                        style: GoogleFonts.barlow(
                            color: const Color.fromARGB(255, 69, 69, 69),
                            fontSize: 20),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      MaterialButton(
                        minWidth: 300,
                        height: 50,
                        onPressed: () {
                          Navigator.pushNamed(context, '/welcomescreen');
                        },
                        color: appcolor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Text("Sign up",
                            style: GoogleFonts.lato(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : ListView(
                  children: [
                    Container(
                        width: double.infinity,
                        height: 230,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(95, 152, 152, 152),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _video == null
                            ? Center(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: _pickVideo,
                                  child: Container(
                                    height: 105,
                                    width: 105,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color.fromARGB(
                                          255, 103, 102, 102),
                                      boxShadow: [
                                        BoxShadow(
                                          color: shadowColor.withOpacity(0.4),
                                          spreadRadius: 5,
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      // ignore: prefer_const_literals_to_create_immutables
                                      children: [
                                        const Icon(
                                          CupertinoIcons.video_camera,
                                          size: 50,
                                          color: Colors.white,
                                        ),
                                        text(
                                            "ڤیدیۆ",
                                            whiteColor,
                                            18,
                                            FontWeight.normal,
                                            TextDirection.rtl)
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : PodVideoPlayer(
                                videoAspectRatio: 2 / 3,
                                backgroundColor: shadowColor,
                                controller: _controller!,
                                alwaysShowProgressBar: true,
                              )),
                    _video == null
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.all(12),
                            child: replaceButton(true),
                          ),
                    const SizedBox(
                      height: 25,
                    ),
                    Container(
                        width: double.infinity,
                        height: 230,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(95, 152, 152, 152),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: thumbnailPic == null
                            ? Center(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: pickThumbnail,
                                  child: Container(
                                    height: 105,
                                    width: 105,
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: shadowColor.withOpacity(0.4),
                                            spreadRadius: 5,
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                        shape: BoxShape.circle,
                                        color: const Color.fromARGB(
                                            255, 103, 102, 102)),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      // ignore: prefer_const_literals_to_create_immutables
                                      children: [
                                        const Icon(
                                          CupertinoIcons.photo,
                                          size: 50,
                                          color: Colors.white,
                                        ),
                                        text(
                                            "بەرگ",
                                            whiteColor,
                                            18,
                                            FontWeight.normal,
                                            TextDirection.rtl)
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: shadowColor,
                                    image: DecorationImage(
                                        image:
                                            FileImage(File(thumbnailPic!.path)),
                                        fit: BoxFit.cover)),
                              )),
                    thumbnailPic == null
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.all(12),
                            child: replaceButton(false),
                          ),
                    const SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        text(
                            "تب: دەبێت لینکی ترەیلەرەکە لە یوتیوبەوە کۆپی بکرێت.",
                            errorColor,
                            16,
                            FontWeight.normal,
                            TextDirection.rtl)
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: youtubelinkValidate != true
                            ? moviePageColor
                            : Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.only(bottom: 5, right: 5, left: 5),
                        child: TextField(
                          autocorrect: true,

                          keyboardType: TextInputType.url,
                          controller: _trailerController,
                          minLines: 1, //Normal textInputField will be displayed
                          maxLines: 5,
                          maxLength: 250,
                          enabled: true,
                          onChanged: (value) {
                            setState(() {
                              _trailer = value;
                              _trailerController;
                            });
                            youtubelinkValidate =
                                validator.validateYouTubeVideoURL(
                              url: _trailer!,
                            );
                          },
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          cursorColor: Colors.amber,
                          decoration: const InputDecoration(
                            hintTextDirection: TextDirection.rtl,
                            border: InputBorder.none,
                            hintText: "لینکی ترەیلەری بەرهەمەکەت لێرەدا دابنێ.",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ));
  }

  replaceButton(
    bool replaceVideo,
  ) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: const Border(
            bottom: BorderSide(color: Colors.white),
            top: BorderSide(color: Colors.white),
            left: BorderSide(color: Colors.white),
            right: BorderSide(color: Colors.white),
          )),
      child: MaterialButton(
          color: moviePageColor,
          minWidth: double.infinity,
          height: 50,
          onPressed: () async {
            if (replaceVideo) {
              await _pickVideo();
            } else {
              await pickThumbnail();
            }
          },
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: text("دووبارە هەڵبژاردن ", whiteColor, 18, FontWeight.w300,
              TextDirection.rtl)),
    );
  }
}

// Navigator.push(
//                               context,
//                               PageTransition(
//                                   type: PageTransitionType.rightToLeft,
//                                   child: Step2(
//                                     userModell: widget.userModell,
//                                     currentUserId: widget.currentUserId,
//                                     video: _video!,
//                                   )));

//  Container(
//                         child: Wrap(
//                           spacing: 5.0,
//                           direction: Axis.horizontal,
//                           children: imagefiles,
//                           alignment: WrapAlignment.spaceEvenly,
//                           runSpacing: 5.0,
//                         ),
//                       ),
