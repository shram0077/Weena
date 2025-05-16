import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Models/ActivityModel.dart';
import 'package:weena_latest/Models/userModel.dart';
import 'package:weena_latest/Screens/SignUP_SignIn/SignIn.dart';
import 'package:weena_latest/Screens/SignUP_SignIn/SignUp.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:weena_latest/Screens/bottomNavigation/bottomNAV.dart';
import 'package:weena_latest/Services/Auth.dart';
import 'package:weena_latest/Services/DatabaseServices.dart';
import 'package:weena_latest/Widgets/widget.dart';

class WelcomeScreen extends StatefulWidget {
  final UserModell? userModell;
  final ActivityModel? activityModel;
  final String? currentUserId;
  final String? visitedUserId;
  final bool isSkiped;
  const WelcomeScreen({
    Key? key,
    this.userModell,
    this.activityModel,
    this.currentUserId,
    this.visitedUserId,
    required this.isSkiped,
  }) : super(key: key);
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;
  bool _isError = false;
  var privacyPolicyUri = "";
  void fetchPrivacyPolicy() async {
    QuerySnapshot collection =
        await FirebaseFirestore.instance.collection('PrivacyPolicy').get();
    var random = Random().nextInt(collection.docs.length);
    DocumentSnapshot randomDoc = collection.docs[random];
    setState(() {
      privacyPolicyUri = randomDoc["uri"];
    });
  }

  @override
  void initState() {
    DatabaseServices.checkVersion(context);
    super.initState();
    fetchPrivacyPolicy();

    _isError = _isError;
    _isLoading = _isLoading;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            widget.isSkiped
                ? Row(children: [backButton(context, 20)])
                : const SizedBox(),
            widget.isSkiped
                ? GestureDetector(
                  onTap: () async {
                    var uri = "https://www.weena.app";
                    if (await canLaunch(uri)) {
                      await launch(uri);
                    } else {
                      throw 'Could not launch $uri';
                    }
                  },
                  child: Text(
                    'weena.app',
                    style: GoogleFonts.barlow(
                      decoration: TextDecoration.underline,
                      color: const Color.fromARGB(255, 189, 33, 22),
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      letterSpacing: 1,
                    ),
                  ),
                )
                : text(
                  'Welcome',
                  appBarColor,
                  30,
                  FontWeight.w500,
                  TextDirection.rtl,
                ),
            Lottie.asset(
              'assets/animations/ActionAnim.json',
              height: 190,
              width: double.infinity,
            ),
            // Container(
            //   height: MediaQuery.of(context).size.height / 4.5,
            //   width: 190,
            //   decoration: const BoxDecoration(
            //       image: DecorationImage(
            //           image: AssetImage(
            //             'assets/images/weena-removebg.png',
            //           ),
            //           fit: BoxFit.cover)),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: text(
                    "گەورەترین خزمەتگوزاری پەخشکردنی فیلم و دراما\n بە بێ بەرامبەر بە ژێرنووسی کوردی.",
                    appBarColor,
                    16,
                    FontWeight.normal,
                    TextDirection.rtl,
                  ),
                ),
              ],
            ),
            //  "گەورەترین خزمەتگوزاری پەخشکردنی فیلم و دراما\n بێ بەرامبەر بە ژێرنووسی کوردی. ",
            Column(
              children: <Widget>[
                MaterialButton(
                  minWidth: 300,
                  height: 50,
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: const SignIn(),
                      ),
                    );
                  },
                  color: moviePageColor.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: text(
                    "Sign in",
                    whiteColor,
                    18,
                    FontWeight.normal,
                    TextDirection.rtl,
                  ),
                ),
                const SizedBox(height: 10),
                MaterialButton(
                  minWidth: 300,
                  height: 50,
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: const SignUp(),
                      ),
                    );
                  },
                  color: moviePageColor.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: text(
                    "Sign up",
                    whiteColor,
                    18,
                    FontWeight.normal,
                    TextDirection.rtl,
                  ),
                ),
              ],
            ),
            widget.isSkiped
                ? const SizedBox()
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    !_isLoading
                        ? InkWell(
                          borderRadius: BorderRadius.circular(10),
                          splashColor: Colors.white,
                          onTap: () async {
                            try {
                              setState(() {
                                _isLoading = true;
                              });

                              bool isValid =
                                  await AuthService.anonymousSignin();
                              if (isValid) {
                                // ignore: use_build_context_synchronously
                                setState(() {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      child: Feed(),
                                    ),
                                  );
                                });
                              } else {
                                setState(() {
                                  _isError = true;
                                });
                                _isLoading = false;
                              }
                            } catch (e) {
                              Fluttertoast.showToast(
                                msg: "$e",
                                backgroundColor: errorColor,
                                textColor: Colors.white,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4.0),
                            width: 200,
                            height: 50,
                            decoration: BoxDecoration(
                              color: moviePageColor.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: appBarColor, width: 1),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                text(
                                  "تێپەڕاندن",
                                  whiteColor,
                                  17.5,
                                  FontWeight.normal,
                                  TextDirection.rtl,
                                ),
                              ],
                            ),
                          ),
                        )
                        : CircleProgressIndicator(),
                  ],
                ),
            GestureDetector(
              onTap: () async {
                var url = privacyPolicyUri;
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  print('Could not launch $url');
                }
              },
              child: Container(
                width: 150,
                padding: EdgeInsets.all(6),
                decoration: ShapeDecoration(
                  color: Color(0x70ECECEC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                child: Center(
                  child: text(
                    'سیاسەتی بەکارهێنان',
                    appBarColor,
                    15,
                    FontWeight.normal,
                    TextDirection.rtl,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
