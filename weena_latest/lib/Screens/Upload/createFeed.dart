import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Widgets/widget.dart';

class CreateFeed extends StatefulWidget {
  final String currentUserId;

  const CreateFeed({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<CreateFeed> createState() => _CreateFeedState();
}

class _CreateFeedState extends State<CreateFeed> {
  bool _isLoading = false;
  String? _description;
  final int _likes = 0;
  final int _dislikes = 0;
  final ImagePicker imgpicker = ImagePicker();
  List<XFile>? imagefiles;
  final TextEditingController _descriptionController = TextEditingController();
  pickImages() async {
    try {
      var pickedfiles = await imgpicker.pickMultiImage();
      //you can use ImageCourse.camera for Camera capture
      if (pickedfiles != null) {
        imagefiles = pickedfiles;
        setState(() {});
      } else {
        print("No image is selected.");
      }
    } catch (e) {
      print("error while picking file.");
    }
  }

// upload to Cloud Storage
  Future<List<String>> uploadImagesToCloudStorage(List<XFile> images) async {
    List<String> imagesUrls = [];
    var postuid = const Uuid().v4();
    images.forEach((image) async {
      setState(() {
        _isLoading = true;
      });
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('Feeds/Feeds OF ${widget.currentUserId}/$postuid.jpg');
      UploadTask uploadTask = storageReference.putFile(File(image.path));
      await uploadTask;

      imagesUrls.add(await storageReference.getDownloadURL());
      // upload to cloud Firestore
      post(imagesUrls, postuid);
      setState(() {
        _isLoading = false;
        imagefiles = null;
      });
    });

    print(imagesUrls);
    return imagesUrls;
  }

// Upload to Cloud Firestore
  Future<void> post(List<String> imageUrls, String postId) async {
    if (imageUrls.isEmpty) {
      setState(() {
        _isLoading = true;
      });
      if (_description == null) {
        setState(() {
          _description = '';
        });
      } else {
        _description = _description;
      }
      await feedsRef
          .doc(widget.currentUserId)
          .collection('Feeds')
          .doc(postId)
          .set({
        "description": _description,
        "images": [],
        "likes": _likes,
        "dislikes": _dislikes,
        "timestamp": Timestamp.now(),
        "postId": postId,
        "ownerId": widget.currentUserId,
        "refeed": 0
      }).whenComplete(() {
        _isLoading = false;
        Navigator.pop(context);
        print('Feeded!');
      });
    } else {
      if (_description == null) {
        setState(() {
          _description = '';
        });
      } else {
        _description = _description;
      }
      setState(() {
        _isLoading = true;
      });
      await feedsRef
          .doc(widget.currentUserId)
          .collection('Feeds')
          .doc(postId)
          .set({
        "description": _description,
        "images": imageUrls,
        "likes": _likes,
        "dislikes": _dislikes,
        "timestamp": Timestamp.now(),
        "postId": postId,
        "ownerId": widget.currentUserId,
        "refeed": 0,
      }).whenComplete(() {
        _isLoading = false;
        Navigator.pop(context);
        print('Feeded!');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: appBarColor,
        appBar: AppBar(
          actions: [
            _descriptionController.text.isEmpty
                ? const SizedBox()
                : _isLoading
                    ? const SizedBox()
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            var postuid = const Uuid().v4();

                            if (imagefiles == null) {
                              post([], postuid);
                            } else {
                              uploadImagesToCloudStorage(imagefiles!);
                            }
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: moviePageColor,
                                borderRadius: BorderRadius.circular(5)),
                            child: Center(
                              child: Text(
                                "پۆست",
                                style: GoogleFonts.barlow(
                                    fontSize: 20,
                                    color: whiteColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      )
          ],
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: backButton(context, 23),
          backgroundColor: appBarColor,
          title: Text(
            'Create Feed',
            style: GoogleFonts.barlow(),
          ),
        ),
        body: ListView(
          children: [
            _isLoading
                ? const LinearProgressIndicator(
                    backgroundColor: whiteColor,
                    color: moviePageColor,
                  )
                : const SizedBox(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5.0, bottom: 7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "چی هەیە چی نییە؟",
                          style: GoogleFonts.barlow(
                              color: whiteColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
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
                        autofocus: true,
                        keyboardType: TextInputType.multiline,
                        controller: _descriptionController,
                        minLines: 1, //Normal textInputField will be displayed
                        maxLines: 5,
                        maxLength: 500,
                        enabled: _isLoading ? false : true,
                        onChanged: (value) {
                          setState(() {
                            _description = value;
                            _descriptionController;
                          });
                        },
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        cursorColor: Colors.amber,
                        decoration: const InputDecoration(
                          hintTextDirection: TextDirection.rtl,
                          border: InputBorder.none,
                          hintText: "شتێک بنووسە دەربارەی پۆستەکەت",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 5, right: 5, left: 5, bottom: 5),
                    child: Row(
                      children: [
                        Container(
                          width: 98,
                          height: 98,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: Colors.grey[900],
                          ),
                          child: Center(
                            child: IconButton(
                                onPressed: () {
                                  pickImages();
                                },
                                icon: const Icon(
                                  CupertinoIcons.camera,
                                  color: whiteColor,
                                  size: 27,
                                )),
                          ),
                        )
                      ],
                    ),
                  ),
                  imagefiles != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'وێنەکان',
                              style: GoogleFonts.barlow(
                                  color: whiteColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        )
                      : const SizedBox(),
                  imagefiles != null
                      ? const Divider(
                          color: Colors.white,
                          thickness: 0.1,
                          indent: 3,
                          endIndent: 3,
                        )
                      : const SizedBox(),
                  imagefiles != null
                      ? Wrap(
                          children: imagefiles!.map((imageone) {
                            return Container(
                                child: Card(
                              child: SizedBox(
                                height: 100,
                                width: 100,
                                child: Image.file(File(imageone.path),
                                    fit: BoxFit.cover),
                              ),
                            ));
                          }).toList(),
                        )
                      : Container()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
