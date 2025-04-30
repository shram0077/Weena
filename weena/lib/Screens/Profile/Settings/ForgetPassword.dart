import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weena/Constant/constant.dart';
import 'package:weena/Widgets/widget.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  bool _isError = false;
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _isError = _isError;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Forget Password?".tr,
            style: GoogleFonts.lato(
                fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: whiteColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 5, bottom: 25),
              child: Container(
                decoration: BoxDecoration(
                    color: const Color.fromARGB(149, 161, 12, 12),
                    borderRadius: BorderRadius.circular(8)),
                child: text(
                    "We send a reset password link to your Email,\n please check your email",
                    Colors.white,
                    16,
                    FontWeight.normal,
                    TextDirection.rtl),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Card(
              elevation: 5,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                    child: TextFormField(
                      style: GoogleFonts.lato(),
                      controller: _emailController,
                      validator: (input) => input!.trim().length < 2
                          ? 'please enter valid email'
                          : null,
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter your email'.tr,
                        hintStyle: GoogleFonts.lato(fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: MaterialButton(
              color: moviePageColor,
              minWidth: double.infinity,
              height: 50,
              onPressed: () async {
                try {
                  _isError = false;
                  await auth.sendPasswordResetEmail(
                      email: _emailController.text.trim());
                  // ignore: use_build_context_synchronously
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: text("باشە", Colors.black, 16,
                                  FontWeight.normal, TextDirection.rtl),
                            )
                          ],
                          content: Text(
                            'We sent a reset password link.'.tr,
                            style: GoogleFonts.barlow(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        );
                      });
                } on FirebaseAuthException catch (e) {
                  setState(() {
                    _isError = true;
                  });
                  print(e);
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: text("باشە", Colors.black, 16,
                                  FontWeight.normal, TextDirection.rtl),
                            )
                          ],
                          content: Text(
                            e.message.toString().tr,
                            style: TextStyle(
                                color: _isError ? Colors.red : Colors.black),
                          ),
                        );
                      });
                }
              },
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Send".tr,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.white),
              ),
            ),
          ),
          _isError
              ? Padding(
                  padding: const EdgeInsets.only(
                    top: 25.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Sorry you're having some trouble!".tr,
                        style: const TextStyle(
                            color: moviePageColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ],
                  ),
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
