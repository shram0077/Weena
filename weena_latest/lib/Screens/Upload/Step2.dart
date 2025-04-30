// ignore: file_names
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pod_player/pod_player.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:uuid/uuid.dart';
import 'package:weena_latest/Services/DatabaseServices.dart';
import 'package:weena_latest/Widgets/widget.dart';
import '../../Constant/constant.dart';

class Step2 extends StatefulWidget {
  final String currentUserId;
  final File video;
  final String trailer;
  final File thumbnailPic;
  const Step2(
      {Key? key,
      required this.currentUserId,
      required this.video,
      required this.thumbnailPic,
      required this.trailer})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _Step2State createState() => _Step2State();
}

class _Step2State extends State<Step2> {
  final descriptionController = TextEditingController();
  final titleController = TextEditingController();
  final imdbController = TextEditingController();

  List<String> listOfValue = [
    'Movie',
    'Drama',
    'Series',
    'Animation',
    "Anime",
  ];

  List<String> resultTags = [];
  List<String> movieORdaram = [];
  String? _typeMovie;
  String? _description;
  String? _title;
  bool? _loading = false;
  ImagePicker picker = ImagePicker();
  double? imdbRating;
  // final FirebaseAuth auth = FirebaseAuth.instance;
  var key;
  Color shadowColor = const Color.fromARGB(255, 125, 123, 123);

  Future uploadFile() async {
    setState(() {
      _loading = true;
    });
    // Upload video
    var uuid = const Uuid().v4();
    UploadTask uploadVideoTask =
        storageRef.child("video's/$_title, $uuid.mp4").putFile(widget.video);
    TaskSnapshot taskSnapshotV = await uploadVideoTask.whenComplete(() => null);
    String videoUrl = await taskSnapshotV.ref.getDownloadURL();

// Upload thumbnail

    UploadTask uploadTask = storageRef
        .child("thumbnail's/$_title, $uuid.jpg")
        .putFile(widget.thumbnailPic);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String thumbUrl = await taskSnapshot.ref.getDownloadURL();

// Upload Trailer
    setState(() {
      // ignore: use_build_context_synchronously
      if (_typeMovie == "Drama") {
        DatabaseServices.uploadVideo(
            titleController.text,
            _description!,
            uuid,
            videoUrl,
            thumbUrl,
            _typeMovie!,
            widget.currentUserId,
            1,
            0,
            context,
            imdbRating!,
            0,
            0,
            widget.currentUserId,
            resultTags,
            widget.trailer);
      } else if (_typeMovie == 'Series') {
        DatabaseServices.uploadVideo(
            titleController.text,
            _description!,
            uuid,
            videoUrl,
            thumbUrl,
            _typeMovie!,
            widget.currentUserId,
            0,
            1,
            context,
            imdbRating!,
            0,
            0,
            widget.currentUserId,
            resultTags,
            widget.trailer);
      } else if (_typeMovie == 'Movie') {
        DatabaseServices.uploadVideo(
            titleController.text,
            _description!,
            uuid,
            videoUrl,
            thumbUrl,
            _typeMovie!,
            widget.currentUserId,
            0,
            0,
            context,
            imdbRating!,
            0,
            0,
            widget.currentUserId,
            resultTags,
            widget.trailer);
      }
      _loading = false;
    });
    return thumbUrl;
  }

  showsuccsesSnackbar(context) {
    return showTopSnackBar(
      context,
      const CustomSnackBar.success(
        message: "Your post has been published",
      ),
    );
  }

  PodPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.file(
        widget.video,
      ),
    )..initialise();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  sendButton() {
    return CupertinoButton(
      // ignore: sort_child_properties_last
      child: text(_loading! ? "دادەنرێ..." : "دانان", errorColor, 19,
          FontWeight.normal, TextDirection.rtl),
      onPressed: _loading!
          ? null
          : () async {
              if (_typeMovie == null) {
                Fluttertoast.showToast(
                    backgroundColor: moviePageColor,
                    textColor: whiteColor,
                    msg: 'جۆری بەرهەمەکە بەتاڵە');
              } else {
                setState(() {
                  _loading = true;
                });

                if (widget.video != null) {
                  if (_typeMovie == null) {
                    _typeMovie = '';
                  } else {
                    _typeMovie = _typeMovie;
                  }
                  if (_typeMovie == null) {
                    _typeMovie = '';
                  } else {
                    _typeMovie = _typeMovie;
                  }
                  if (_title == null) {
                    _title = '';
                  } else {
                    _title = _title;
                  }
                } else {
                  Fluttertoast.showToast(msg: 'no found images');
                }
                try {
                  uploadFile();
                } catch (e) {
                  print(e);
                }
              }
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBarColor,
      appBar: AppBar(
          elevation: 0,
          actions: [sendButton()],
          centerTitle: true,
          title: text('هەنگاوی دووەم', whiteColor, 19, FontWeight.normal,
              TextDirection.rtl),
          backgroundColor: appBarColor,
          automaticallyImplyLeading: false,
          leading: _loading! ? const SizedBox() : const BackButton()),
      body: ListView(
        shrinkWrap: true,
        children: [
          _loading!
              ? const LinearProgressIndicator(
                  color: Colors.white,
                  backgroundColor: appcolor,
                  minHeight: 2,
                )
              : const SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 2),
                  child: Row(
                    children: [
                      Icon(
                        FlutterIcons.title_mdi,
                        color: errorColor,
                        size: 17,
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(bottom: 5, right: 5, left: 5),
                    child: TextField(
                      autocorrect: true,

                      keyboardType: TextInputType.url,
                      controller: titleController,
                      minLines: 1, //Normal textInputField will be displayed
                      maxLines: 5,
                      maxLength: 60,
                      enabled: true,
                      onChanged: (value) {
                        setState(() {
                          _title = value;
                          titleController;
                        });
                      },
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      cursorColor: moviePageColor,
                      decoration: const InputDecoration(
                        hintTextDirection: TextDirection.rtl,
                        border: InputBorder.none,
                        hintText: "ناوی بەرهەم (تایتڵ)",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 5, left: 8.0, bottom: 2),
                  child: Row(
                    children: [
                      Icon(
                        FlutterIcons.note_mdi,
                        color: errorColor,
                        size: 17,
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(bottom: 5, right: 5, left: 5),
                    child: TextField(
                      autocorrect: true,

                      keyboardType: TextInputType.url,
                      controller: descriptionController,
                      minLines: 5, //Normal textInputField will be displayed
                      maxLines: 8,
                      maxLength: 300,
                      enabled: true,
                      onChanged: (value) {
                        setState(() {
                          _description = value;
                          descriptionController;
                        });
                      },
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      cursorColor: moviePageColor,
                      decoration: const InputDecoration(
                        hintTextDirection: TextDirection.rtl,
                        border: InputBorder.none,
                        hintText: "کورتەی بەرهەم (وەسف)",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0, right: 3),
                        child: Container(
                          width: 26,
                          height: 24,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(7),
                                  topRight: Radius.circular(7)),
                              color: Color.fromARGB(255, 27, 26, 26),
                              image: DecorationImage(
                                  image: AssetImage('assets/images/imdb.png'))),
                        ),
                      ),
                      text("ڕەیتینگ", errorColor, 16, FontWeight.normal,
                          TextDirection.rtl)
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(bottom: 5, right: 5, left: 5),
                    child: TextField(
                      autocorrect: true,

                      keyboardType: TextInputType.number,
                      controller: imdbController,
                      minLines: 1, //Normal textInputField will be displayed
                      maxLines: 5,
                      maxLength: 60,
                      enabled: true,
                      onChanged: (value) {
                        setState(() {
                          imdbRating = double.parse(value);
                          imdbController;
                        });
                      },
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      cursorColor: moviePageColor,
                      decoration: const InputDecoration(
                        hintTextDirection: TextDirection.ltr,
                        border: InputBorder.none,
                        hintText: "ڕەیتینگ",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    text("جۆری بەرهەم", errorColor, 16, FontWeight.normal,
                        TextDirection.rtl)
                  ],
                ),
                Column(
                  children: [
                    Card(
                      color: Colors.grey[900],
                      child: DropdownButtonFormField<String>(
                        dropdownColor: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        focusColor: moviePageColor,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(5)),
                        isExpanded: true,
                        value: _typeMovie,
                        hint: text('فیلم،دراما،زنجیرە...', Colors.grey, 16,
                            FontWeight.normal, TextDirection.rtl),
                        onChanged: (value) {
                          setState(() {
                            _typeMovie = value;
                          });
                        },
                        onSaved: (value) {
                          setState(() {
                            _typeMovie = value;
                          });
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "can't empty";
                          } else {
                            return null;
                          }
                        },
                        items: listOfValue.map((String val) {
                          return DropdownMenuItem(
                            value: val,
                            child: Text(
                              val.tr,
                              style: const TextStyle(
                                  color: whiteColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(
            color: Colors.white,
            height: 2,
            indent: 0.2,
            endIndent: 0.2,
            thickness: 0.2,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              text(
                  "ژانەر", errorColor, 16, FontWeight.normal, TextDirection.rtl)
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(tags.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          resultTags.add(tags[index]);
                        });
                      },
                      child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[900],
                          ),
                          child: text(tags[index], whiteColor, 14,
                              FontWeight.normal, TextDirection.rtl)),
                    ),
                  );
                }),
              ),
            ),
          ),
          const Divider(
            color: Colors.white,
            height: 2,
            indent: 0.2,
            endIndent: 0.2,
            thickness: 0.2,
          ),
          Row(
            children: List.generate(resultTags.length, (index) {
              return Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      resultTags.remove(resultTags[index]);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: errorColor,
                    ),
                    child: Text(
                      resultTags[index],
                      style: GoogleFonts.barlow(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            }),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: PodVideoPlayer(
                backgroundColor: shadowColor,
                controller: _controller!,
                alwaysShowProgressBar: true,
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              height: 205,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: shadowColor,
                  image: DecorationImage(
                      image: FileImage(File(widget.thumbnailPic.path)),
                      fit: BoxFit.cover)),
            ),
          ),
        ],
      ),
    );
  }
}
