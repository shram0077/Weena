import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Models/userModel.dart';
import 'package:weena_latest/Services/DatabaseServices.dart';
import 'package:weena_latest/Widgets/widget.dart';
import 'package:weena_latest/encryption_decryption/encryption.dart';

class BecamePublisher extends StatefulWidget {
  final String currentUserId;
  final UserModell userModell;
  const BecamePublisher(
      {Key? key, required this.currentUserId, required this.userModell})
      : super(key: key);
  @override
  State<BecamePublisher> createState() => _BecamePublisherState();
}

class _BecamePublisherState extends State<BecamePublisher> {
  List<String> listOfValue = [
    'تەنها فیید',
    'تەنها فیلم یان دراما',
    'هەردووکیان'
  ];
  String? _username;
  String? _typeOFRequest;
  String? _cityorTown;
  String? _country;
  bool _sending = true;

  final _auth = FirebaseAuth.instance;
  bool _isUserEmailVerified = false;
  checkEmail() async {
    await FirebaseAuth.instance.currentUser!.reload();
    if (_auth.currentUser!.emailVerified) {
      setState(() {
        _isUserEmailVerified == _auth.currentUser!.emailVerified;
        print(_isUserEmailVerified);
      });
    }
  }

  bool _isSent = false;
  IsSent() async {
    bool isLikedThisPost = await DatabaseServices.isSentRequest(
      widget.currentUserId,
    );
    setState(() {
      _isSent = isLikedThisPost;
    });
  }

  @override
  void initState() {
    _isUserEmailVerified = _auth.currentUser!.emailVerified;
    checkEmail();
    IsSent();
    super.initState();

    _username = widget.userModell.username;
    _country = "کوردستان - عێراق";
    _cityorTown = widget.userModell.cityorTown;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBarColor,
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: shadowColor,
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        MyEncriptionDecription.decryptWithAESKey(
                            widget.userModell.profilePicture),
                      ),
                      fit: BoxFit.cover)),
            ),
          )
        ],
        centerTitle: true,
        title: text("ناردنی داواکاری بڵاوکەرەوە", whiteColor, 15,
            FontWeight.normal, TextDirection.rtl),
        backgroundColor: appBarColor,
        automaticallyImplyLeading: false,
        leading: backButton(context, 23),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: _isUserEmailVerified
              ? _isSent
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          FlutterIcons.email_check_outline_mco,
                          size: 100,
                          color: Colors.yellow,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Flexible(
                            child: text(
                                "نێردراوە،تکایە ئەگەر زۆر لە چاوەڕوانیدای دەتوانی پەیوەندیمان پێوە بکەیت.",
                                Colors.yellow,
                                14,
                                FontWeight.normal,
                                TextDirection.rtl)),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                                padding:
                                    const EdgeInsets.only(left: 3, right: 3),
                                child: GestureDetector(
                                  onTap: () async {
                                    var url =
                                        "https://www.facebook.com/weenakrd";
                                    if (await canLaunch(url)) {
                                      await launch(url);
                                    } else {
                                      print('Could not launch $url');
                                    }
                                  },
                                  child: socialMediaButton(
                                      Colors.blue, FontAwesome.facebook),
                                )),
                            Padding(
                                padding:
                                    const EdgeInsets.only(left: 3, right: 3),
                                child: GestureDetector(
                                  onTap: () async {
                                    var url =
                                        'https://www.instagram.com/shrammahmuud';
                                    if (await canLaunch(url)) {
                                      await launch(url);
                                    } else {
                                      print('Could not launch $url');
                                    }
                                  },
                                  child: socialMediaButton(
                                      const Color.fromARGB(255, 244, 45, 111),
                                      FontAwesome.instagram),
                                )),
                          ],
                        )
                      ],
                    )
                  : ListView(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            text("Username", whiteColor, 13, FontWeight.normal,
                                TextDirection.rtl)
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 5.0, bottom: 3),
                            child: TextFormField(
                              enabled: false,
                              initialValue: _username,
                              style: GoogleFonts.lato(fontSize: 19),
                              obscureText: false,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'username'.tr,
                                hintStyle: GoogleFonts.lato(fontSize: 14),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            text("جۆری داواکاری", whiteColor, 13,
                                FontWeight.normal, TextDirection.rtl)
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            width: 160,
                            height: 50,
                            decoration: BoxDecoration(
                                color: shadowColor.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10)),
                            child: SizedBox(
                              width: 180,
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(8)),
                                isExpanded: true,
                                value: _typeOFRequest,
                                dropdownColor: shadowColor.withOpacity(0.5),
                                iconEnabledColor: Colors.white,
                                focusColor: Colors.white,
                                hint: const Text(
                                  'جۆری داواکاری',
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(color: Colors.white),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _typeOFRequest = value;
                                  });
                                },
                                onSaved: (value) {
                                  setState(() {
                                    _typeOFRequest = value;
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
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            text("وڵات یان هەرێم", whiteColor, 13,
                                FontWeight.normal, TextDirection.rtl)
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 5.0, bottom: 4),
                            child: TextFormField(
                              maxLength: 500,
                              initialValue: _country,
                              style: GoogleFonts.lato(fontSize: 19),
                              enabled: false,
                              obscureText: false,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Country'.tr,
                                hintStyle: GoogleFonts.lato(fontSize: 14),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        widget.userModell.cityorTown.isEmpty
                            ? const Divider()
                            : const SizedBox(),
                        widget.userModell.cityorTown.isEmpty
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  text("شار یان شارۆچکەکەت بنووسە.", whiteColor,
                                      13, FontWeight.normal, TextDirection.rtl)
                                ],
                              )
                            : const SizedBox(),
                        widget.userModell.cityorTown.isEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5.0, bottom: 4),
                                  child: TextFormField(
                                    enabled: _sending,
                                    maxLength: 500,
                                    initialValue: _cityorTown,
                                    style: GoogleFonts.lato(fontSize: 19),
                                    onChanged: (value) {
                                      _cityorTown = value;
                                    },
                                    obscureText: false,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintText: 'City / Town'.tr,
                                      hintStyle: GoogleFonts.lato(fontSize: 14),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                  child: text(
                                      "تێبینی:پاش ئەوەی ئەکاونتەکەت قبوڵ کرا لەلایەن ئێمەوە،دەبێت چالاکیەکانت زیاتر بکەیت.",
                                      Colors.yellow,
                                      12,
                                      FontWeight.normal,
                                      TextDirection.rtl))
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MaterialButton(
                              color: shadowColor.withOpacity(0.2),
                              splashColor: Colors.transparent,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("CANCEL".tr,
                                  style: const TextStyle(
                                      fontSize: 14, color: whiteColor)),
                            ),
                            MaterialButton(
                                splashColor:
                                    const Color.fromARGB(0, 255, 214, 64),
                                onPressed: () {
                                  sendRequest();
                                },
                                color: Colors.yellow,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 50),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                child: _sending
                                    ? Text(
                                        "ناردن".tr,
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.black),
                                      )
                                    : const CupertinoActivityIndicator())
                          ],
                        ),
                      ],
                    )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      FlutterIcons.email_alert_mco,
                      size: 100,
                      color: Colors.yellow,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Flexible(
                        child: text(
                            'ناتوانی ئەم کردارە جێ بە جێ بکەیت لەبەر ئەوەی ئیمەیڵەکەت نەسەلمێنراوە',
                            Colors.yellow,
                            14,
                            FontWeight.normal,
                            TextDirection.rtl)),
                    const SizedBox(
                      height: 15,
                    ),
                    InkWell(
                      onTap: () {
                        if (_isUserEmailVerified) {
                          // TODO: implement your code after email verification
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Your email has been successfully verified"
                                      .tr)));
                        } else {
                          try {
                            FirebaseAuth.instance.currentUser
                                ?.sendEmailVerification();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("ئیمەیڵەکەت بپشکنە".tr)));
                          } catch (e) {
                            Fluttertoast.showToast(msg: '$e');
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: moviePageColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: text("Verify", Colors.yellow, 12,
                            FontWeight.bold, TextDirection.rtl),
                      ),
                    ),
                  ],
                )),
    );
  }

  void sendRequest() async {
    setState(() {
      _sending = false;
    });
    try {
      if (_typeOFRequest.isNull) {
        Fluttertoast.showToast(msg: 'جۆری داواکاری بەتاڵە.');
      } else {
        await requestsRef.doc(widget.currentUserId).set({
          "Username": _username,
          "Display Name": widget.userModell.name,
          "Type of Request": _typeOFRequest,
          "Country": _country,
          "City or town": _cityorTown,
          "Timestamp": Timestamp.now(),
          "UserId": widget.currentUserId,
          "Email": widget.userModell.email, // Decrypte Email;
        }).whenComplete(() {
          setState(() {
            _sending = true;
            Fluttertoast.showToast(msg: 'نێردرا');
            IsSent();
          });
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _sending = true;
      });
    }
  }
}
