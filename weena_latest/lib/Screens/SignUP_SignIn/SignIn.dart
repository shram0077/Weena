import 'package:lottie/lottie.dart';
import 'package:weena_latest/Models/ActivityModel.dart';
import 'package:weena_latest/Models/userModel.dart';
import 'package:weena_latest/Screens/Profile/Settings/ForgetPassword.dart';
import 'package:weena_latest/Screens/SignUP_SignIn/SignUp.dart';
import 'package:weena_latest/Services/DatabaseServices.dart';
import 'package:weena_latest/Widgets/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import '../../../Constant/constant.dart';
import '../../../Services/Auth.dart';

class SignIn extends StatefulWidget {
  final String? currentUserId;
  final String? visitedUserId;

  final UserModell? userModel;
  final ActivityModel? activityModel;

  const SignIn(
      {Key? key,
      this.currentUserId,
      this.visitedUserId,
      this.userModel,
      this.activityModel})
      : super(key: key);
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  late String _email;
  late String _password;
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _isLoading = false;
  bool _isError = false;
  bool _isSpacing = false;
  String errorMessageforEmailFiled = '';
  String errorMessageforUserNameFiled = '';
  @override
  void initState() {
    super.initState();
    _isError = _isError;
    _isLoading = _isLoading;
    _isSpacing = _isSpacing;
    _obscureText = _obscureText;
    DatabaseServices.checkVersion(context);
  }

  String? validateEmail(String? value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return 'Enter Valid Email';
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
              height: MediaQuery.of(context).size.height - 20,
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
                          )),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: text("Sign in", appBarColor, 33,
                            FontWeight.normal, TextDirection.rtl),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Form(
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
                            color: _isSpacing
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
                                              "Please enter valid email".tr;
                                          _isSpacing = true;
                                        } else {
                                          _email = value;
                                          errorMessageforEmailFiled = '';
                                          _isSpacing = false;
                                        }
                                      });
                                    },
                                    validator: (input) => input!.length < 3
                                        ? 'Please enter valid email'.tr
                                        : null,
                                    obscureText: false,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      errorStyle: TextStyle(color: Colors.red),
                                      errorText:
                                          errorMessageforEmailFiled.isEmpty
                                              ? null
                                              : errorMessageforEmailFiled,
                                      hintTextDirection: TextDirection.rtl,
                                      hintText: 'Enter your email'.tr,
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
                                    validator: (input) =>
                                        input!.trim().length < 8
                                            ? 'Please enter valid password'.tr
                                            : null,
                                    obscureText:
                                        _obscureText == true ? true : false,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintTextDirection: TextDirection.rtl,
                                      hintText: 'Enter your Password'.tr,
                                      hintStyle: GoogleFonts.lato(fontSize: 16),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 4.0, top: 7, bottom: 4),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgetPasswordScreen()),
                                  );
                                },
                                child: text("Forget Password?", appBarColor, 13,
                                    FontWeight.w500, TextDirection.rtl),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  _isError
                      ? text(
                          "Please Enter The Correct Email And Password!",
                          errorColor.withOpacity(0.8),
                          16,
                          FontWeight.w600,
                          TextDirection.ltr)
                      : const SizedBox(),
                  _isLoading
                      ? CircleProgressIndicator()
                      : _isSpacing != true
                          ? Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: appBarColor, width: 1)),
                              child: MaterialButton(
                                color: _isError
                                    ? errorColor.withOpacity(0.8)
                                    : moviePageColor,
                                minWidth: double.infinity,
                                height: 50,
                                onPressed: () async {
                                  try {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      bool isValid = await AuthService.login(
                                          _email, _password, context);
                                      if (isValid) {
                                        // ignore: use_build_context_synchronously
                                        setState(() {
                                          Navigator.pushNamedAndRemoveUntil(
                                              context, '/feed', (_) => false);
                                        });
                                      } else {
                                        setState(() {
                                          _isError = true;
                                        });
                                        _isLoading = false;
                                      }
                                    }
                                  } catch (e) {
                                    // ignore: avoid_print
                                    print('This Error$e');
                                  }
                                },
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: text("Sign in", whiteColor, 18,
                                    FontWeight.w600, TextDirection.rtl),
                              ),
                            )
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
                                  child: SignUp()));
                        },
                        child: text(
                            "Sign up",
                            const Color.fromARGB(255, 173, 34, 24),
                            12.5,
                            FontWeight.w700,
                            TextDirection.rtl),
                      ),
                      text(" | ", appBarColor, 12.5, FontWeight.bold,
                          TextDirection.ltr),
                      text("I don't have an account ", appBarColor, 13,
                          FontWeight.w500, TextDirection.rtl),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
