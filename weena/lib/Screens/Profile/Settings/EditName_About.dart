import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:weena/Models/userModel.dart';

import '../../../Constant/constant.dart';
import '../../../Services/DatabaseServices.dart';
import '../../../Widgets/widget.dart';

class EditeName extends StatefulWidget {
  final user;
  final String visitedUserId;
  final String currentUserId;
  const EditeName(
      {super.key,
      required this.user,
      required this.visitedUserId,
      required this.currentUserId});
  @override
  _EditeNameState createState() => _EditeNameState();
}

class _EditeNameState extends State<EditeName> {
  late String _name;
  late String _bio;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  get joinedAt => null;

  saveProfile() async {
    _formKey.currentState!.save();
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() {
        _isLoading = true;
      });
      String profilePictureUrl = '';
      UserModell user = UserModell(
          pushToken: widget.user.pushToken,
          username: widget.user.username,
          activeTime: widget.user.activeTime,
          coverPicture: widget.user.coverPicture,
          id: widget.user.id,
          admin: widget.user.admin,
          name: _name,
          profilePicture: profilePictureUrl,
          bio: _bio,
          email: '',
          verification: widget.user.verification,
          joinedAt: widget.user.joinedAt,
          isVerified: widget.user.isVerified,
          cityorTown: widget.user.cityorTown,
          country: widget.user.country,
          type: widget.user.type);

      DatabaseServices.updateUserDisplayName(user);
      var key;

      Fluttertoast.showToast(
          msg: 'بەسەرکەوتووی ناوەکەت گۆردرا',
          backgroundColor: Colors.green,
          toastLength: Toast.LENGTH_LONG,
          textColor: whiteColor);
      Navigator.pop(context);
    }
  }

  showsuccsesSnackbar(context) {
    return showTopSnackBar(
      context,
      CustomSnackBar.success(
        icon: const Icon(
          CupertinoIcons.person_circle_fill,
          color: Colors.white,
        ),
        iconPositionLeft: 8,
        message: "Your display Name was successfully updated".tr,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _name = widget.user.name;
    _bio = widget.user.bio;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text(
          'DisplayName'.tr,
          style: GoogleFonts.lato(fontSize: 20, color: Colors.black),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: whiteColor,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        children: [
          Container(
            transform: Matrix4.translationValues(0, -40, 0),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Column(
              children: [
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 5.0, bottom: 4),
                            child: TextFormField(
                              initialValue: _name,
                              style: GoogleFonts.lato(fontSize: 19),
                              onChanged: (value) {
                                _name = value;
                              },
                              validator: (input) => input!.length < 3
                                  ? 'Please enter valid name'.tr
                                  : null,
                              obscureText: false,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'ناوەکەت بنووسە'.tr,
                                hintStyle: GoogleFonts.lato(fontSize: 14),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MaterialButton(
                              color: const Color.fromARGB(200, 71, 68, 68),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("CANCEL".tr,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ),
                            MaterialButton(
                              splashColor:
                                  const Color.fromARGB(0, 255, 214, 64),
                              onPressed: () {
                                saveProfile();
                              },
                              color: moviePageColor,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                "SAVE".tr,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 30),
                        _isLoading
                            ? CircleProgressIndicator()
                            : const SizedBox.shrink()
                      ],
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }
}
// Edite About

class EditeAbout extends StatefulWidget {
  final user;
  final String visitedUserId;
  final String currentUserId;
  const EditeAbout(
      {super.key,
      required this.user,
      required this.visitedUserId,
      required this.currentUserId});
  @override
  _EditeAboutState createState() => _EditeAboutState();
}

class _EditeAboutState extends State<EditeAbout> {
  late String _name;
  late String _bio;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  saveProfile() async {
    _formKey.currentState!.save();
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() {
        _isLoading = true;
      });
      String profilePictureUrl = '';
      UserModell user = UserModell(
          pushToken: widget.user.pushToken,
          username: widget.user.username,
          activeTime: widget.user.activeTime,
          cityorTown: widget.user.cityorTown,
          country: widget.user.country,
          coverPicture: widget.user.coverPicture,
          admin: widget.user.admin,
          id: widget.user.id,
          name: _name,
          profilePicture: profilePictureUrl,
          bio: _bio,
          email: '',
          verification: widget.user.verification,
          joinedAt: widget.user.joinedAt,
          isVerified: widget.user.isVerified,
          type: widget.user.type);

      DatabaseServices.updateAboutUser(user);

      Fluttertoast.showToast(
          msg: 'بەسەرکەوتووی بایۆکەت گۆردرا',
          backgroundColor: Colors.green,
          toastLength: Toast.LENGTH_LONG,
          textColor: whiteColor);
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _bio = widget.user.bio;
    _name = widget.user.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
          title: Text(
            'Bio'.tr,
            style: GoogleFonts.lato(fontSize: 20, color: Colors.black),
          ),
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: whiteColor,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ))),
      body: FutureBuilder(
          future: usersRef.doc(auth.currentUser!.uid).get(),
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
                Container(
                  transform: Matrix4.translationValues(0, -40, 0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: Column(
                    children: [
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 30),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5.0, bottom: 4),
                                  child: TextFormField(
                                    textDirection: TextDirection.rtl,
                                    maxLength: 500,
                                    maxLines: 4,
                                    initialValue: _bio,
                                    style: GoogleFonts.lato(fontSize: 19),
                                    onChanged: (value) {
                                      _bio = value;
                                    },
                                    obscureText: false,
                                    keyboardType: TextInputType.multiline,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your bio'.tr,
                                      hintStyle: GoogleFonts.lato(fontSize: 14),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MaterialButton(
                                    color:
                                        const Color.fromARGB(200, 71, 68, 68),
                                    splashColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("CANCEL".tr,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: whiteColor)),
                                  ),
                                  MaterialButton(
                                    splashColor:
                                        const Color.fromARGB(0, 255, 214, 64),
                                    onPressed: () {
                                      saveProfile();
                                    },
                                    color: moviePageColor,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Text(
                                      "SAVE".tr,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 30),
                              _isLoading
                                  ? CircleProgressIndicator()
                                  : const SizedBox.shrink()
                            ],
                          )),
                    ],
                  ),
                )
              ],
            );
          }),
    );
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  void inputData() async {
    final user = auth.currentUser!;
    final userid = user.uid;
  }
}
