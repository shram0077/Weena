import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:weena/Constant/constant.dart';
import 'package:weena/Models/userModel.dart';
import 'package:weena/Screens/Profile/Settings/EditName_About.dart';
import 'package:weena/Widgets/widget.dart';
import 'package:weena/encryption_decryption/encryption.dart';

class EditeProfile extends StatefulWidget {
  final String currentUserId;
  final String visitedUserId;
  final UserModell userModel;
  const EditeProfile(
      {super.key,
      required this.currentUserId,
      required this.userModel,
      required this.visitedUserId});

  @override
  State<EditeProfile> createState() => _EditeProfileState();
}

class _EditeProfileState extends State<EditeProfile> {
  late String _name;
  late String _bio;
  final _formKey = GlobalKey<FormState>();
  final _fireStore = FirebaseFirestore.instance;
  bool _isLoading = false;
  late String url = '';
  late String coverUrl = '';
  ImagePicker image = ImagePicker();
  Uint8List? imageBytes;
  File? file;
  File? coverPicture;
  CroppedFile? _croppedFile;
  // Pick Profile Image
  pickProfileImage() async {
    final XFile? img = await image.pickImage(source: ImageSource.gallery);
    _croppImageProfile(imageFile: File(img!.path));
  }

  Future<File?> _croppImageProfile({required File imageFile}) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop the image',
            toolbarColor: Colors.indigo,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true),
        IOSUiSettings(
          title: 'Crop the image',
        ),
      ],
    );
    if (croppedFile == null) {
      return null;
    } else {
      setState(() {
        file = File(croppedFile.path);
      });
    }
    return null;
  }

  // Pick Cover picture
  pickCoverPicture() async {
    final XFile? imgcover = await image.pickImage(source: ImageSource.gallery);
    _croppImageCover(imageFile: File(imgcover!.path));
    setState(() {
      coverPicture = File(imgcover.path);
    });
  }

  Future<File?> _croppImageCover({required File imageFile}) async {
    CroppedFile? croppedFile =
        await ImageCropper().cropImage(sourcePath: imageFile.path);
    if (croppedFile == null) {
      return null;
    } else {
      setState(() {
        coverPicture = File(croppedFile.path);
      });
    }
    return null;
  }

  final FirebaseAuth auth = FirebaseAuth.instance;

// Upload Profile Picture
  uploadProfilePicture() async {
    if (file != null) {
      setState(() {
        _isLoading = true;
      });
      var imageFile = FirebaseStorage.instance
          .ref()
          .child('profilePicture')
          .child(
              'profilePicture/users/userProfile_${widget.currentUserId}.jpg');
      UploadTask task = imageFile.putFile(file!);
      TaskSnapshot taskSnapshot = await task;
      // for downloading
      url = await taskSnapshot.ref.getDownloadURL();
      print('This Orginal URL: $url');
      _fireStore.collection('users').doc(auth.currentUser!.uid).update({
        'profilePicture': MyEncriptionDecription.encryptWithAESKey(url),
      });
      Navigator.pop(context);
      return true;
    } else {
      return null;
    }
  }

// Upload Cover Picture
  uploadCoverPicture() async {
    if (coverPicture != null) {
      setState(() {
        _isLoading = true;
      });
      var imageFile = FirebaseStorage.instance
          .ref()
          .child('coverPicture')
          .child('coverPicture/users/userCover_${widget.currentUserId}.jpg');
      UploadTask task = imageFile.putFile(coverPicture!);
      TaskSnapshot taskSnapshot = await task;
      // for downloading
      url = await taskSnapshot.ref.getDownloadURL();
      print('This Orginal URL: $url');
      _fireStore.collection('users').doc(auth.currentUser!.uid).update({
        'coverPicture': MyEncriptionDecription.encryptWithAESKey(url),
      });
      setState(() {
        Navigator.pop(context);
      });
      return true;
    } else {
      return null;
    }
  }

  saveProfile() {
    if (coverPicture != null && file != null) {
      uploadCoverPicture();
      uploadProfilePicture();
    } else if (coverPicture != null) {
      uploadCoverPicture();
    } else if (file != null) {
      uploadProfilePicture();
    }
  }

  @override
  void initState() {
    super.initState();
    _name = widget.userModel.name;
    _bio = widget.userModel.bio;
    coverPicture = coverPicture;
    file = file;
  }

  var user;
  var key;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Edit Your Profile'.tr,
            style: GoogleFonts.lato(fontSize: 20, color: Colors.black)),
        elevation: 0.5,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        actions: [
          CupertinoButton(
              child: Text(
                'Save'.tr,
                style: GoogleFonts.alef(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                    color: Colors.black),
              ),
              onPressed: () {
                _isLoading ? null : saveProfile();
              })
        ],
        automaticallyImplyLeading: false,
        backgroundColor: whiteColor,
      ),
      body: FutureBuilder(
          future: usersRef.doc(widget.currentUserId).get(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircleProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Have Something Error!',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              );
            }
            UserModell userModel = UserModell.fromDoc(snapshot.data);
            return ListView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              children: [
                Stack(
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(211, 231, 233, 243),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: coverPicture == null
                                  ? userModel.coverPicture.isEmpty
                                      ? CachedNetworkImageProvider(
                                          MyEncriptionDecription
                                              .decryptWithAESKey(
                                                  userModel.profilePicture))
                                      : CachedNetworkImageProvider(
                                          MyEncriptionDecription
                                              .decryptWithAESKey(
                                                  userModel.coverPicture))
                                  : FileImage(File(coverPicture!.path))
                                      as ImageProvider),
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(6),
                              bottomRight: Radius.circular(6))),
                    ),
                    GestureDetector(
                      onTap: () {
                        pickCoverPicture();
                      },
                      child: Container(
                          height: 200,
                          color: const Color.fromARGB(91, 61, 60, 60),
                          child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.camera,
                                  size: 50,
                                  color: Color.fromARGB(167, 255, 255, 255),
                                )
                              ])),
                    )
                  ],
                ),
                Container(
                  transform: Matrix4.translationValues(0.0, -55.0, 0.0),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  height: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 10),
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            height: 120,
                            decoration: BoxDecoration(
                              color: profileBGcolor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(255, 123, 83, 78)
                                      .withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: file == null
                                    ? CachedNetworkImage(
                                        imageUrl: MyEncriptionDecription
                                            .decryptWithAESKey(
                                          userModel.profilePicture,
                                        ),
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(File(file!.path))),
                          ),
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  pickProfileImage();
                                },
                                child: Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 2,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                    ),
                                    color: shadowColor.withOpacity(0.9),
                                  ),
                                  child: const Icon(Icons.edit,
                                      color: Colors.white),
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'DisplayName'.tr,
                      style: GoogleFonts.lato(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                  child: GestureDetector(
                      onTap: () {
                        var user;
                        var key;
                        _isLoading
                            ? null
                            : Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.bottomToTop,
                                    child: EditeName(
                                      currentUserId: widget.currentUserId,
                                      visitedUserId: widget.userModel.id,
                                      user: userModel,
                                    )));
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                            color: shadowColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Flexible(
                                fit: FlexFit.loose,
                                child: Text(
                                  widget.userModel.name,
                                  style: GoogleFonts.lato(
                                    color: Colors.grey[700],
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Bio'.tr,
                      style: GoogleFonts.lato(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                  child: GestureDetector(
                      onTap: () {
                        var user;
                        var key;
                        _isLoading
                            ? null
                            : Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.bottomToTop,
                                    child: EditeAbout(
                                      currentUserId: widget.currentUserId,
                                      visitedUserId: widget.userModel.id,
                                      user: userModel,
                                    )));
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                            color: shadowColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.userModel.bio,
                                  style: GoogleFonts.lato(
                                    color: Colors.grey[700],
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(child: _isLoading ? CircleProgressIndicator() : null),
              ],
            );
          }),
    );
  }
}
