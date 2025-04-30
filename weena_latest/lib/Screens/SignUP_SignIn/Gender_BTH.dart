// ignore_for_file: prefer_final_fields, unused_field, use_build_context_synchronously

import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Services/Auth.dart';
import 'package:weena_latest/Widgets/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class GenderandBirthday extends StatefulWidget {
  final String username;
  final String email;
  final String password;
  final String dislayName;
  final bool isSigninWithPhoneNumber;
  final String phoneNumber;
  final bool isSignInWithGoogle;
  const GenderandBirthday(
      {Key? key,
      required this.username,
      required this.email,
      required this.password,
      required this.dislayName,
      required this.isSigninWithPhoneNumber,
      required this.phoneNumber,
      required this.isSignInWithGoogle})
      : super(key: key);
  @override
  State<GenderandBirthday> createState() => _GenderandBirthdayState();
}

class _GenderandBirthdayState extends State<GenderandBirthday> {
  List<String> listOfValue = ['نێر', 'مێ', 'بڵاوکەر'];
  String? _gender;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isError = false;
  DateTime dateTime = DateTime(2000, 1, 1, 10, 20);

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: whiteColor,
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleProgressIndicator(),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            )
          : ListView(
              children: [
                Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 10),
                      width: double.infinity,
                      child: Column(
                        children: [
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
                          const SizedBox(
                            height: 30,
                          ),
                          Text("کەی ڕۆژی لەدایک بوونتە؟",
                              style: GoogleFonts.barlow(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: appBarColor)),
                          const SizedBox(
                            height: 10,
                          ),
                          Card(
                              color: Colors.grey[200],
                              elevation: 1,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                width: double.infinity,
                                height: 50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${dateTime.month}/${dateTime.day}/${dateTime.year}",
                                      style: GoogleFonts.lato(fontSize: 16),
                                    ),
                                  ],
                                ),
                              )),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              width: 200,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: moviePageColor,
                                  borderRadius: BorderRadius.circular(15)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () {
                                  showCupertinoModalPopup(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          SizedBox(
                                            height: 250,
                                            child: CupertinoDatePicker(
                                              backgroundColor: Colors.grey[300],
                                              initialDateTime: dateTime,
                                              maximumYear: 2006,
                                              minimumYear: 1950,
                                              mode:
                                                  CupertinoDatePickerMode.date,
                                              onDateTimeChanged:
                                                  (DateTime newTime) {
                                                setState(() {
                                                  dateTime = newTime;
                                                });
                                              },
                                            ),
                                          ));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.date_range_outlined,
                                      size: 19,
                                      color: whiteColor,
                                    ),
                                    const SizedBox(
                                      width: 3,
                                    ),
                                    Text(
                                      'ڕۆژی لەدایک بوون هەڵبژێرە',
                                      style: GoogleFonts.lato(
                                          color: whiteColor,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text("ڕەگەزی تۆ چییە؟",
                              style: GoogleFonts.barlow(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: appBarColor)),
                          const SizedBox(
                            height: 10,
                          ),
                          Card(
                              color: Colors.grey[200],
                              elevation: 1,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                width: double.infinity,
                                height: 50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      _gender == null
                                          ? "ڕەگەز لێرەدا دەردەکەوێت"
                                          : _gender.toString(),
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                          color: _gender == null
                                              ? Colors.grey
                                              : Colors.black,
                                          fontSize: 15),
                                    ),
                                  ],
                                ),
                              )),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Container(
                              width: 160,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: moviePageColor,
                                  borderRadius: BorderRadius.circular(15)),
                              child: SizedBox(
                                width: 180,
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(8)),
                                  isExpanded: true,
                                  value: _gender,
                                  dropdownColor: moviePageColor,
                                  iconEnabledColor: Colors.white,
                                  focusColor: Colors.white,
                                  hint: const Text(
                                    'ڕەگەز',
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _gender = value;
                                    });
                                  },
                                  onSaved: (value) {
                                    setState(() {
                                      _gender = value;
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
                                        val,
                                        textDirection: TextDirection.rtl,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 70.0, right: 20, left: 20, bottom: 10),
                            child: MaterialButton(
                              color: _isError ? errorColor : moviePageColor,
                              minWidth: double.infinity,
                              height: 50,
                              onPressed: () async {
                                bool isValid = await AuthService.signUp(
                                    widget.dislayName,
                                    widget.email,
                                    widget.password,
                                    _gender!,
                                    false,
                                    widget.username,
                                    dateTime,
                                    context);
                                if (isValid) {
                                  Navigator.pushNamed(
                                    context,
                                    "/feed",
                                  );
                                } else {
                                  setState(() {
                                    _isError = true;
                                  });
                                  _isLoading = false;
                                }
                                // try {
                                //   if (_formKey.currentState!.validate() &&
                                //       _gender != null) {
                                //     setState(() {
                                //       _isLoading = true;
                                //     });

                                //   }

                                // } catch (e) {
                                //   print("Error=>: $e");
                                //   Fluttertoast.showToast(
                                //     msg: "دڵنیا بەرەوە لە فۆڕمەکان",
                                //     backgroundColor: moviePageColor,
                                //     textColor: whiteColor,
                                //   );
                                //   setState(() {
                                //     _isLoading = false;
                                //   });
                                // }
                              },
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "Next".tr,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  genderIsEmpty() {
    return Fluttertoast.showToast(
        backgroundColor: Colors.grey.shade600, msg: 'تکایە رەگەزەکەت هەڵبژێرە');
  }
}
