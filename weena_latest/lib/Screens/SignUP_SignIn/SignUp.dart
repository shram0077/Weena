import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Models/ActivityModel.dart';
import 'package:weena_latest/Models/userModel.dart';
import 'package:weena_latest/Screens/SignUP_SignIn/Gender_BTH.dart';
import 'package:weena_latest/Screens/SignUP_SignIn/SignIn.dart';
import 'package:weena_latest/Services/DatabaseServices.dart';
import 'package:weena_latest/Widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class SignUp extends StatefulWidget {
  final String? currentUserId;
  final String? visitedUserId;

  final UserModell? userModel;
  final ActivityModel? activityModel;

  const SignUp(
      {Key? key,
      this.currentUserId,
      this.visitedUserId,
      this.userModel,
      this.activityModel})
      : super(key: key);
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late String _email;
  String? _username;
  String? _displayName;
  late String _password;
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _isLoading = false;
  bool _isError = false;
  bool _isSpacingUsername = false;
  bool _isSpacingEmail = false;

  bool usernameIsAlreadyTaken = false;
  bool emailIsAlreadyHaveUsed = false;
  String errorMessageforEmailFiled = '';
  String errorMessageforUserNameFiled = '';
  @override
  void initState() {
    super.initState();
    _isError = _isError;
    _isLoading = _isLoading;
    _isSpacingEmail = _isSpacingEmail;
    _isSpacingUsername = _isSpacingUsername;
    DatabaseServices.checkVersion(context);
  }

  String? validateEmail(String? value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return 'Please enter valid email'.tr;
    } else {
      return null;
    }
  }

  String? validateUsername(String? value) {
    String pattern =
        r'ABCDEFGHIJKLMNOPQRSTUVWXYZ^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$   ';
    RegExp regex = RegExp(pattern);
    if (regex.hasMatch(value!)) {
      return 'Please enter valid username'.tr;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: ListView(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: appBarColor,
                          ))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: text(
                            "Sign up",
                            _isError ? Colors.red : appBarColor,
                            33,
                            FontWeight.normal,
                            TextDirection.rtl),
                      ),
                    ],
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10.0, top: 2),
                              child: text("Email", appBarColor, 14,
                                  FontWeight.normal, TextDirection.rtl),
                            ),
                          ],
                        ),
                        Card(
                          color: _isSpacingEmail
                              ? Color.fromARGB(255, 242, 32, 17)
                              : Colors.grey[200],
                          elevation: 1,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, bottom: 5),
                                child: TextFormField(
                                  cursorColor: Colors.red,
                                  style: GoogleFonts.lato(fontSize: 16),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value.contains(' ')) {
                                        errorMessageforEmailFiled =
                                            'Please enter valid email'.tr;
                                        _isSpacingEmail = true;
                                      } else {
                                        _email = value;
                                        errorMessageforEmailFiled = '';
                                        _isSpacingEmail = false;
                                      }
                                    });
                                  },
                                  validator: validateEmail,
                                  obscureText: false,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    errorStyle: TextStyle(color: Colors.red),
                                    errorText: errorMessageforEmailFiled.isEmpty
                                        ? null
                                        : errorMessageforEmailFiled,
                                    hintTextDirection: TextDirection.rtl,
                                    hintText: 'Enter the email'.tr,
                                    hintStyle: GoogleFonts.lato(fontSize: 16),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10.0, top: 2),
                              child: text("Username", appBarColor, 14,
                                  FontWeight.normal, TextDirection.rtl),
                            ),
                          ],
                        ),
                        Card(
                          color: _isSpacingUsername
                              ? Color.fromARGB(255, 242, 32, 17)
                              : Colors.grey[200],
                          elevation: 1,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, bottom: 5),
                                child: TextFormField(
                                  cursorColor: Colors.red,
                                  style: GoogleFonts.lato(fontSize: 16),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value.contains(' ')) {
                                        errorMessageforUserNameFiled =
                                            'Enter the vaild username'.tr;
                                        _isSpacingUsername = true;
                                      } else {
                                        _username = value;
                                        errorMessageforUserNameFiled = '';
                                        _isSpacingUsername = false;
                                      }
                                    });
                                  },
                                  validator: validateUsername,
                                  obscureText: false,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    errorStyle: TextStyle(color: appBarColor),
                                    errorText:
                                        errorMessageforUserNameFiled.isEmpty
                                            ? null
                                            : errorMessageforUserNameFiled,
                                    hintTextDirection: TextDirection.rtl,
                                    hintText: 'Enter the vaild username'.tr,
                                    hintStyle: GoogleFonts.lato(fontSize: 16),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ignore: prefer_const_constructors
                        if (usernameIsAlreadyTaken)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: text('پێشتر ئەم ناوە گیراوە', errorColor,
                                    14, FontWeight.w600, TextDirection.rtl),
                              ),
                            ],
                          )
                        else
                          const SizedBox(),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10.0, top: 2),
                              child: text("DisplayName", appBarColor, 14,
                                  FontWeight.normal, TextDirection.rtl),
                            ),
                          ],
                        ),
                        Card(
                          color: Colors.grey[200],
                          elevation: 1,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, bottom: 5),
                                child: TextFormField(
                                  cursorColor: Colors.red,
                                  style: GoogleFonts.lato(fontSize: 16),
                                  onChanged: (value) {
                                    _displayName = value;
                                  },
                                  validator: (input) => input!.trim().length <
                                              2 &&
                                          input.trim().length > 9
                                      ? 'Display Name must be more than 2 character'
                                          .tr
                                      : null,
                                  obscureText: false,
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    hintTextDirection: TextDirection.rtl,
                                    hintText: 'Enter the DisplayName'.tr,
                                    hintStyle: GoogleFonts.lato(fontSize: 16),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10.0, top: 2),
                              child: text("Password", appBarColor, 14,
                                  FontWeight.normal, TextDirection.rtl),
                            ),
                          ],
                        ),
                        Card(
                          color: Colors.grey[200],
                          elevation: 1,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, bottom: 5),
                                child: TextFormField(
                                  cursorColor: Colors.red,
                                  style: GoogleFonts.lato(fontSize: 16),
                                  onChanged: (value) {
                                    _password = value;
                                  },
                                  validator: (input) => input!.trim().length < 8
                                      ? 'Please enter valid password'.tr
                                      : null,
                                  obscureText: _obscureText,
                                  keyboardType: TextInputType.visiblePassword,
                                  decoration: InputDecoration(
                                    hintTextDirection: TextDirection.rtl,
                                    hintText: 'Enter the Password'.tr,
                                    hintStyle: GoogleFonts.lato(fontSize: 16),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0, top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    if (_obscureText == true) {
                                      setState(() {
                                        _obscureText = false;
                                      });
                                    } else if (_obscureText == false) {
                                      setState(() {
                                        _obscureText = true;
                                      });
                                    }
                                  },
                                  child: Icon(
                                    _obscureText
                                        ? CupertinoIcons.eye_slash_fill
                                        : CupertinoIcons.eye,
                                    color: !_obscureText
                                        ? moviePageColor
                                        : Colors.black,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _isError
                      ? text("Please Enter The Correct Email And Password",
                          errorColor, 16, FontWeight.w600, TextDirection.ltr)
                      : const SizedBox(),
                  if (_isLoading)
                    CircleProgressIndicator()
                  else
                    _isSpacingEmail != true
                        ? _isSpacingUsername != true
                            ? Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: appBarColor, width: 1)),
                                child: MaterialButton(
                                    color: _isError
                                        ? errorColor.withOpacity(0.8)
                                        : moviePageColor,
                                    minWidth: double.infinity,
                                    height: 50,
                                    onPressed: () async {
                                      // Snap Username
                                      QuerySnapshot snapUsername =
                                          await usersRef
                                              .where("username",
                                                  isEqualTo: _username)
                                              .get();
                                      //
                                      if (snapUsername.docs.isNotEmpty) {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        print(
                                            'ناوی بەکارهێنەری $_username بەردەست نییە.');
                                        setState(() {
                                          usernameIsAlreadyTaken = true;
                                        });
                                      } else {
                                        try {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            // ignore: use_build_context_synchronously
                                            bool isValid = await Navigator.push(
                                                context,
                                                PageTransition(
                                                    type: PageTransitionType
                                                        .rightToLeft,
                                                    child: GenderandBirthday(
                                                      dislayName: _displayName!,
                                                      email: _email,
                                                      password: _password,
                                                      username: _username!,
                                                      isSigninWithPhoneNumber:
                                                          false,
                                                      phoneNumber: '',
                                                      isSignInWithGoogle: false,
                                                    )));

                                            if (isValid) {
                                              setState(() {});
                                            } else {
                                              setState(() {
                                                _isError = true;
                                              });
                                              setState(() {
                                                _isLoading = false;
                                              });
                                            }
                                          }
                                        } catch (e) {
                                          print('This Error$e');
                                        }
                                      }
                                    },
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: text("Next", whiteColor, 18,
                                        FontWeight.w600, TextDirection.ltr)),
                              )
                            : SizedBox()
                        : SizedBox(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.leftToRight,
                                    child: SignIn(
                                      activityModel: widget.activityModel,
                                      currentUserId: widget.currentUserId,
                                      userModel: widget.userModel,
                                      visitedUserId: widget.visitedUserId,
                                    )));
                          },
                          child: text(
                              "Sign in",
                              const Color.fromARGB(255, 173, 34, 24),
                              12.5,
                              FontWeight.bold,
                              TextDirection.ltr)),
                      text(" | ", appBarColor, 12.5, FontWeight.bold,
                          TextDirection.ltr),
                      text("I have an account ", appBarColor, 12.5,
                          FontWeight.w500, TextDirection.ltr)
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
