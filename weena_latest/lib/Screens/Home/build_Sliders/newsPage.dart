import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:weena_latest/APi/apis.dart';
import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Models/userModel.dart';
import 'package:weena_latest/Screens/Profile/profile.dart';
import 'package:weena_latest/Widgets/widget.dart';
import 'package:weena_latest/encryption_decryption/encryption.dart';

class NewsPage extends StatefulWidget {
  final String byUserId;
  final String newsTitle;
  final String description;
  final Timestamp timestamp;
  final String picture;
  final dynamic views;
  final String newsID;
  const NewsPage(
      {Key? key,
      required this.byUserId,
      required this.newsTitle,
      required this.description,
      required this.timestamp,
      required this.picture,
      required this.views,
      required this.newsID})
      : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  @override
  void initState() {
    // TODO: implement initState
    APi.getSelfInfo();
    Future.delayed(const Duration(seconds: 5), () {
      newsRef
          .doc(widget.newsID)
          .update({"views": APi.myid.codeUnitAt(widget.views)});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: appBarColor,
        body: StreamBuilder(
            stream: usersRef.doc(widget.byUserId).snapshots(),
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

              UserModell userModel = UserModell.fromDoc(snapshot.data);
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        )
                      ],
                    ),
                  ),
                  Opacity(
                      opacity: 0.8,
                      child: CachedNetworkImage(
                        imageUrl: widget.picture,
                        fit: BoxFit.contain,
                      )),
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8)),
                        color: Color.fromARGB(255, 16, 16, 16)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Profile Circles
                        InkWell(
                          borderRadius: BorderRadius.circular(6),
                          splashColor: shadowColor.withOpacity(0.2),
                          onTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.topToBottom,
                                    child: ProfileScreen(
                                      userModel: userModel,
                                      visitedUserId: userModel.id,
                                      currentUserId: APi.myid,
                                    )));
                          },
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(23),
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                          MyEncriptionDecription
                                              .decryptWithAESKey(
                                                  userModel.profilePicture)),
                                      fit: BoxFit.cover,
                                      opacity: 35,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color(0xFF292b37)),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                userModel.name,
                                style: GoogleFonts.barlow(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: shadowColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.eye,
                                color: Colors.white,
                                size: 19,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                widget.views.length.toString(),
                                textAlign: TextAlign.end,
                                style: GoogleFonts.barlow(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: shadowColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.clock,
                                color: Colors.white,
                                size: 19,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                "${widget.timestamp.toDate().year.toString()}/${widget.timestamp.toDate().month.toString()}/${widget.timestamp.toDate().day.toString()}",
                                textAlign: TextAlign.end,
                                style: GoogleFonts.barlow(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 0.1,
                  ),
                  Flexible(
                    child: Column(
                      children: [
                        text(widget.newsTitle, whiteColor, 22,
                            FontWeight.normal, TextDirection.rtl),
                        const SizedBox(
                          height: 4,
                        ),
                        text(
                            widget.description,
                            const Color.fromARGB(255, 177, 177, 177),
                            18,
                            FontWeight.normal,
                            TextDirection.rtl)
                      ],
                    ),
                  )
                ],
              );
            }));
  }
}
