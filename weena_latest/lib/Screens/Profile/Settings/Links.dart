import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Models/linksModel.dart';
import 'package:weena_latest/Services/DatabaseServices.dart';
import 'package:weena_latest/Widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Links extends StatefulWidget {
  final String currentUserId;

  const Links({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<Links> createState() => _LinksState();
}

class _LinksState extends State<Links> {
  String? _facebook;
  String? _youtube;
  String? _instagram;

  saveLinks() {
    LinksModel links = LinksModel(
        instagram: _instagram!, youtube: _youtube!, facebook: _facebook!);
    DatabaseServices.updateLinks(widget.currentUserId, links, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'بەستەرەکان',
          style: GoogleFonts.barlow(
            color: Colors.black,
          ),
        ),
        backgroundColor: whiteColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          // ignore: prefer_const_constructors
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 23,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: StreamBuilder(
            stream: linksRef.doc(widget.currentUserId).snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.only(top: 300.0),
                  child: Center(child: CircleProgressIndicator()),
                );
                // ignore: unrelated_type_equality_checks
              } else if (snapshot == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.only(top: 300.0),
                  child: Center(child: CircleProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Snapshot Error',
                          style: GoogleFonts.alef(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: errorColor)),
                    ],
                  ),
                );
              }

              LinksModel linksModel = LinksModel.fromDoc(snapshot.data);
              _facebook = linksModel.facebook;
              _instagram = linksModel.instagram;
              _youtube = linksModel.youtube;
              return Column(children: [
                // Facebook
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 5),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(5)),
                        padding: const EdgeInsets.all(5),
                        child: const Icon(
                          FontAwesome.facebook,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5.0, bottom: 4),
                    child: TextFormField(
                      maxLength: 50,
                      initialValue: _facebook,
                      style: GoogleFonts.lato(fontSize: 19),
                      onChanged: (value) {
                        _facebook = value;
                      },
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Facebook'.tr,
                        hintStyle: GoogleFonts.lato(fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                // Insatgram
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 2, top: 10),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.pink,
                            borderRadius: BorderRadius.circular(5)),
                        padding: const EdgeInsets.all(5),
                        child: const Icon(
                          FontAwesome.instagram,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5.0, bottom: 4),
                    child: TextFormField(
                      maxLength: 50,
                      initialValue: _instagram,
                      style: GoogleFonts.lato(fontSize: 19),
                      onChanged: (value) {
                        _instagram = value;
                      },
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Instagram'.tr,
                        hintStyle: GoogleFonts.lato(fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                // Youtube
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 2, top: 10),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.all(5),
                        child: const Icon(
                          FontAwesome.youtube_play,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5.0, bottom: 4),
                    child: TextFormField(
                      maxLength: 50,
                      initialValue: _youtube,
                      style: GoogleFonts.lato(fontSize: 19),
                      onChanged: (value) {
                        _youtube = value;
                      },
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'YouTube'.tr,
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
                      color: Color.fromARGB(200, 71, 68, 68),
                      splashColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
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
                      splashColor: const Color.fromARGB(0, 255, 214, 64),
                      onPressed: () async {
                        saveLinks();
                      },
                      color: moviePageColor,
                      padding: const EdgeInsets.symmetric(horizontal: 50),
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
              ]);
            }),
      ),
    );
  }
}
