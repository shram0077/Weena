import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:weena/Models/ChatModel.dart';
import 'package:weena/Models/userModel.dart';
import 'package:weena/Screens/Profile/profile.dart';
import 'package:weena/encryption_decryption/encryption.dart';

import '../../Constant/constant.dart';
import '../../Services/DatabaseServices.dart';
import '../../Widgets/widget.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'ChatsScreen.dart';

class ListUsers extends StatefulWidget {
  final String? currentUserId;
  final String? visitedUserId;

  const ListUsers({super.key, this.currentUserId, this.visitedUserId});

  @override
  State<ListUsers> createState() => _ListUsersState();
}

class _ListUsersState extends State<ListUsers> with WidgetsBindingObserver {
  List _addedusers = [];
  var key;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  getaddedUsers() async {
    List<ChatModel> users = await DatabaseServices.getCollectionChats(
      _auth.currentUser!.uid,
    );
    if (mounted) {
      setState(() {
        _addedusers = users.toList();
      });
      print('This Result: ${_addedusers.length}');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    didChangeAppLifecycleState(AppLifecycleState.resumed);
    getaddedUsers();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Timer.periodic(const Duration(seconds: 1), (timer) async {
        getaddedUsers();
      });
    } else {}
  }

  buildchats(ChatModel chatModel) {
    return StreamBuilder(
        stream: usersRef.doc(chatModel.visitedUserId).snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return listcacheUI();
          } else {
            UserModell user = UserModell.fromDoc(snapshot.data);
            return Column(
              children: [
                Card(
                  color: whiteColor,
                  elevation: 1,
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: ChatScreen(
                                pushToken: user.pushToken,
                                userModell: user,
                                name: user.name,
                                profilePicture: user.profilePicture,
                                lastSeen: chatModel.lastSeen,
                                key: key,
                                currentUserId: _auth.currentUser!.uid,
                                visitedUserId: chatModel.visitedUserId,
                              )));
                      setState(() {
                        getaddedUsers();
                      });
                    },
                    onLongPress: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext bc) {
                            return Container(
                              child: Wrap(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: InkWell(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Icon(
                                              AntDesign.close,
                                            )),
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Row(
                                      children: [
                                        Text(user.name,
                                            style: GoogleFonts.barlow(
                                              letterSpacing: 1,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            )),
                                      ],
                                    ),
                                  ),
                                  ListTile(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              type: PageTransitionType
                                                  .rightToLeft,
                                              child: ProfileScreen(
                                                userModel: user,
                                                currentUserId:
                                                    widget.currentUserId!,
                                                visitedUserId:
                                                    chatModel.visitedUserId,
                                                key: key,
                                              )));
                                    },
                                    leading: const Icon(
                                        CupertinoIcons.person_circle),
                                    title: Text('Profile'.tr,
                                        style: GoogleFonts.abel(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        )),
                                  ),
                                  ListTile(
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              type: PageTransitionType
                                                  .rightToLeft,
                                              child: ChatScreen(
                                                pushToken: user.pushToken,
                                                userModell: user,
                                                name: user.name,
                                                profilePicture:
                                                    user.profilePicture,
                                                lastSeen: chatModel.lastSeen,
                                                key: key,
                                                currentUserId:
                                                    widget.currentUserId!,
                                                visitedUserId:
                                                    chatModel.visitedUserId,
                                              )));
                                      getaddedUsers();
                                    },
                                    leading: const Icon(
                                      CupertinoIcons.chat_bubble_text,
                                    ),
                                    title: Text(
                                      'چات',
                                      style: GoogleFonts.lato(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    onTap: () {
                                      DatabaseServices.removeCollection(
                                          _auth.currentUser!.uid, user.id);
                                      getaddedUsers();
                                      Navigator.pop(context);
                                    },
                                    leading: const Icon(
                                      CupertinoIcons.chat_bubble_text,
                                    ),
                                    title: Text(
                                      'سڕینەوەلەلیستی چات',
                                      style: GoogleFonts.lato(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          });
                    },
                    textColor: Colors.black,
                    leading: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: ChatScreen(
                                    pushToken: user.pushToken,
                                    name: user.name,
                                    userModell: user,
                                    profilePicture: user.profilePicture,
                                    lastSeen: chatModel.lastSeen,
                                    key: key,
                                    currentUserId: widget.currentUserId!,
                                    visitedUserId: chatModel.visitedUserId,
                                  )));
                        },
                        child: squareProfilePicture(user, 45, 45, 10, false)),
                    title: Row(
                      children: [
                        Text(user.name,
                            style: const TextStyle(
                                color: appBarColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        const SizedBox(
                          width: 3,
                        ),
                        user.verification
                            ? verfiedBadge(19, 19)
                            : const SizedBox(),
                        user.admin
                            ? adminBadge(
                                20,
                                20,
                              )
                            : const SizedBox(),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                            '${timeago.format(chatModel.lastMessagetimestamp.toDate())} ',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 155, 155, 155),
                                fontSize: 10.5)),
                        const SizedBox(
                          width: 5,
                        ),
                        chatModel.lastMessagetext == ""
                            ? Container(
                                padding: const EdgeInsets.only(
                                    left: 5, right: 5, top: 0, bottom: 0),
                                decoration: BoxDecoration(
                                    color: textBlueColor.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(4)),
                                child: text("نوێ", whiteColor, 10,
                                    FontWeight.normal, TextDirection.rtl),
                              )
                            : const SizedBox(),
                        const Spacer(),
                        chatModel.isRead != true
                            ? Container(
                                padding: const EdgeInsets.only(
                                    left: 5, right: 5, top: 0, bottom: 0),
                                decoration: BoxDecoration(
                                    color: moviePageColor,
                                    borderRadius: BorderRadius.circular(4)),
                                child: text("پەیامێکت بۆ هاتووە", whiteColor,
                                    11.5, FontWeight.normal, TextDirection.rtl),
                              )
                            : const SizedBox()
                      ],
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_sharp,
                      color: Colors.grey,
                    ),
                  ),
                ),
                //
              ],
            );
          }
        });
  }

  squareProfilePicture(UserModell user, double height, double width,
      double raduis, bool isEmptyProfileuri) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: ProfileScreen(
                    currentUserId: widget.currentUserId!,
                    userModel: user,
                    visitedUserId: user.id,
                  )));
        },
        child: Container(
          padding: const EdgeInsets.all(1),
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(raduis),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 78, 89, 123).withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isEmptyProfileuri
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(raduis),
                  child: CachedNetworkImage(
                    imageUrl: 'assets/images/person.png',
                    fit: BoxFit.cover,
                    width: width,
                    height: height,
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(raduis),
                  child: CachedNetworkImage(
                    imageUrl: MyEncriptionDecription.decryptWithAESKey(
                        user.profilePicture),
                    fit: BoxFit.cover,
                    width: width,
                    height: height,
                  ),
                ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (isAnonymous) {
      return Scaffold(
        backgroundColor: whiteColor,
        body: shouldbeSignedup(context, false),
      );
    } else {
      return Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          actions: const [
            // IconButton(
            //     onPressed: () {
            //       Navigator.push(
            //           context,
            //           PageTransition(
            //               type: PageTransitionType.rightToLeft,
            //               child: NeabyUsersScreen(
            //                 myModel: APi.me,
            //               )));
            //     },
            //     icon: Icon(
            //       CupertinoIcons.person_3_fill,
            //       color: whiteColor,
            //       size: 27,
            //     ))
          ],
          backgroundColor: whiteColor,
          elevation: 0,
          centerTitle: true,
          title: text("زیادکراوەکان", appBarColor, 20, FontWeight.normal,
              TextDirection.rtl),
        ),
        body: RefreshIndicator(
            strokeWidth: 2,
            color: Colors.white,
            backgroundColor: moviePageColor,
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            onRefresh: () => getaddedUsers(),
            child: setUpLoading()),
      );
    }
  }

  bool isAnonymous = FirebaseAuth.instance.currentUser!.isAnonymous;
  Widget setUpLoading() {
    if (isAnonymous) {
      return shouldbeSignedup(context, false);
    } else {
      if (_addedusers.isEmpty) {
        return Center(
          child: text("هیچ کەسێکت زیاد نەکردووە.", whiteColor, 20,
              FontWeight.normal, TextDirection.rtl),
        );
      } else {
        return ListView.builder(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            itemCount: _addedusers.length,
            itemBuilder: (BuildContext context, int index) {
              ChatModel chatModel = _addedusers[index];
              return Padding(
                  padding: const EdgeInsets.only(
                    left: 1,
                    right: 1,
                  ),
                  child: buildchats(chatModel));
            });
      }
    }
  }
}
