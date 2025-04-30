import 'package:cached_network_image/cached_network_image.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:weena/APi/apis.dart';
import 'package:weena/Models/Post.dart';
import 'package:weena/Models/userModel.dart';
import 'package:weena/Screens/MoviePage/movie_page.dart';
import 'package:weena/encryption_decryption/encryption.dart';
import '../../Constant/constant.dart';
import '../../Services/DatabaseServices.dart';
import '../../Widgets/widget.dart';
import '../Profile/profile.dart';

class SearchSC extends StatefulWidget {
  final bool? fromDashdboard;
  final String? currentUserId;
  final String? fromDashdboardTags;
  const SearchSC({
    super.key,
    this.currentUserId,
    this.fromDashdboard,
    this.fromDashdboardTags,
  });
  @override
  // ignore: library_private_types_in_public_api
  _SearchSCState createState() => _SearchSCState();
}

class _SearchSCState extends State<SearchSC> {
  Future<QuerySnapshot>? _users;
  Future<QuerySnapshot>? _posts;
  var key;

  buildPostCard(PostModel postModel) {
    return StreamBuilder(
        stream: usersRef.doc(postModel.userId).snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircleProgressIndicator());
            // ignore: unrelated_type_equality_checks
          } else if (snapshot == ConnectionState.waiting) {
            return Center(child: CircleProgressIndicator());
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
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 123, 27, 27),
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    subtitle: Flexible(
                      child: Text(
                        "پوختە:  ${postModel.description}",
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.barlow(
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(255, 234, 232, 232)),
                      ),
                    ),
                    trailing: Text(
                      postModel.userId == widget.currentUserId
                          ? "Me".tr
                          : userModel.username,
                      style: GoogleFonts.barlow(
                          color: whiteColor.withOpacity(0.9),
                          fontWeight: FontWeight.bold),
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(1),
                      height: 60,
                      width: 55,
                      decoration: BoxDecoration(
                        color: profileBGcolor,
                        borderRadius: BorderRadius.circular(12),
                        // ignore: prefer_const_literals_to_create_immutables
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: CachedNetworkImage(
                          imageUrl: postModel.thumbnail,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              postModel.title,
                              style: GoogleFonts.barlow(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: whiteColor),
                            ),
                          ),
                          postModel.verified
                              ? verfiedBadgeForPost(19, 19)
                              : const SizedBox(),
                          const Spacer(),
                          Text(
                            postModel.type.tr,
                            style: GoogleFonts.barlow(
                                color: whiteColor.withOpacity(0.9),
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: MoviePage(
                                postModel: postModel,
                                userModell: userModel,
                                currentUserId: APi.myid,
                              )));
                    },
                  ),
                ),
              ),
            ],
          );
        });
  }

  buildUserTile(UserModell user) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 138, 27, 27),
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              subtitle: Row(
                children: [
                  Text(
                    '@${user.username}',
                    style: GoogleFonts.barlow(
                        color: Colors.grey[400], fontWeight: FontWeight.w600),
                  )
                ],
              ),
              trailing: Text(
                user.id == widget.currentUserId ? "Me".tr : '',
                style: const TextStyle(color: whiteColor),
              ),
              leading: Container(
                padding: const EdgeInsets.all(2),
                height: 55,
                width: 55,
                decoration: BoxDecoration(
                  color: profileBGcolor,
                  borderRadius: BorderRadius.circular(15),
                  // ignore: prefer_const_literals_to_create_immutables
                  boxShadow: [
                    const BoxShadow(
                      color: appcolor,
                      spreadRadius: 0.1,
                      blurRadius: 0.1,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: MyEncriptionDecription.decryptWithAESKey(
                        user.profilePicture),
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: GoogleFonts.barlow(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: whiteColor),
                  ),
                  user.verification
                      ? verfiedBadgeForPost(16, 16)
                      : const SizedBox()
                ],
              ),
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: ProfileScreen(
                          currentUserId: widget.currentUserId!,
                          visitedUserId: user.id,
                          userModel: user,
                          key: key,
                        )));
              },
            ),
          ),
        ),
      ],
    );
  }

  final _searchController = TextEditingController();
  @override
  void initState() {
    if (widget.fromDashdboardTags!.isNotEmpty) {
      setState(() {
        _posts = DatabaseServices.searchPostsbyTags(
            widget.fromDashdboardTags.toString());
      });
    } else {}
    DatabaseServices.checkVersion(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      animationDuration: const Duration(milliseconds: 400),
      child: Scaffold(
          backgroundColor: whiteColor,
          appBar: AppBar(
              bottom: const TabBar(
                  splashBorderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8)),
                  indicatorWeight: 4,
                  indicatorColor: moviePageColor,
                  tabs: [
                    Tab(
                      icon: Icon(
                        FlutterIcons.movie_open_outline_mco,
                        color: Colors.black,
                      ),
                    ),
                    Tab(
                        icon: Icon(
                      FlutterIcons.users_fea,
                      color: Colors.black,
                    )),
                  ]),
              titleSpacing: 5,
              automaticallyImplyLeading: false,
              backgroundColor: whiteColor,
              centerTitle: true,
              leading: widget.fromDashdboard!
                  ? IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                        size: 23,
                      ),
                    )
                  : const SizedBox(),
              actions: [
                _posts != null
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _posts = null;
                          });
                        },
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.black,
                        ),
                      )
                    : const SizedBox()
              ],
              elevation: 0,
              title: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 9),
                child: Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(bottom: 1, right: 8, left: 8),
                        child: TextFormField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.black),
                          cursorColor: Colors.red,
                          onChanged: (v) {
                            if (v.isNotEmpty) {
                              setState(() {
                                _users = DatabaseServices.searchUsers(
                                  v,
                                );
                                _posts = DatabaseServices.searchPosts(
                                  v[0].toUpperCase() + v.substring(1),
                                );
                              });
                            } else {
                              _users == null;
                              _posts == null;
                            }
                          },
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(
                                  top: 0, bottom: 1.5, right: 1),
                              hintText: 'Search'.tr,
                              hintTextDirection: TextDirection.rtl,
                              // ignore: unnecessary_const
                              hintStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF545454)),
                              border: InputBorder.none),
                        ),
                      ),
                    )),
              )),
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _posts == null
                  ? Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 50,
                          color: const Color.fromARGB(143, 242, 242, 242),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              textDirection: TextDirection.rtl,
                              children: List.generate(tags.length, (index) {
                                return Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _posts =
                                            DatabaseServices.searchPostsbyTags(
                                                tags[index]);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: moviePageColor,
                                      ),
                                      child: text(
                                          tags[index].tr,
                                          whiteColor,
                                          13,
                                          FontWeight.normal,
                                          TextDirection.rtl),
                                    ),
                                  ),
                                );

                                // Padding(
                                //   padding: const EdgeInsets.all(5.0),
                                //   child: GestureDetector(
                                //     onTap: () {
                                //       setState(() {
                                //         _posts =
                                //             DatabaseServices.searchPostsbyTags(
                                //                 tags[index]);
                                //       });
                                //     },
                                //     child: Container(
                                //       padding: const EdgeInsets.all(5),
                                //       decoration: BoxDecoration(
                                //         borderRadius: BorderRadius.circular(8),
                                //         color: shadowColor.withOpacity(0.2),
                                //       ),
                                //       child: text(
                                //           tags[index].tr,
                                //           whiteColor,
                                //           13,
                                //           FontWeight.normal,
                                //           TextDirection.rtl),
                                //     ),
                                //   ),
                                // );
                              }),
                            ),
                          ),
                        ),
                        const Divider(
                          color: whiteColor,
                          indent: 1,
                          endIndent: 1,
                          height: 0.3,
                        ),
                      ],
                    )
                  : FutureBuilder(
                      future: _posts,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return Column(
                            children: [
                              listcacheUI(),
                            ],
                          );
                        }
                        if (snapshot.data.docs.length == 0) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('No posts found!'.tr,
                                    style: GoogleFonts.alef(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: whiteColor)),
                              ],
                            ),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircleProgressIndicator(),
                          );
                        }
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (BuildContext context, int index) {
                              PostModel postModel =
                                  PostModel.fromDoc(snapshot.data.docs[index]);
                              return buildPostCard(postModel);
                            });
                      }),
              _users == null
                  ? Center(
                      child: text('بگەڕێ', whiteColor, 20, FontWeight.normal,
                          TextDirection.rtl))
                  : FutureBuilder(
                      future: _users,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return Column(
                            children: [
                              listcacheUI(),
                              Row(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          left: 12, top: 5),
                                      child: Text(
                                          '"${_searchController.text} " گەڕان بۆ'
                                              .tr,
                                          style: GoogleFonts.krub(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ))),
                                ],
                              )
                            ],
                          );
                        } else {}
                        if (snapshot.data.docs.length == 0) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('No users found!'.tr,
                                    style: GoogleFonts.alef(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: whiteColor)),
                              ],
                            ),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircleProgressIndicator(),
                          );
                        }
                        return ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (BuildContext context, int index) {
                              UserModell user =
                                  UserModell.fromDoc(snapshot.data.docs[index]);
                              return buildUserTile(user);
                            });
                      }),
            ],
          )),
    );
  }

  Widget buildUsers() {
    return FutureBuilder(
        future: _users,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Column(
              children: [
                listcacheUI(),
                Row(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 12, top: 5),
                        child: Text('گەڕان بۆ... "${_searchController.text}"',
                            style: GoogleFonts.krub(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ))),
                  ],
                )
              ],
            );
          } else {}
          if (snapshot.data.docs.length == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No users found!'.tr,
                      style: GoogleFonts.alef(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      )),
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircleProgressIndicator(),
            );
          }
          return ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext context, int index) {
                UserModell user = UserModell.fromDoc(snapshot.data.docs[index]);
                return buildUserTile(user);
              });
        });
  }

  buildPost() {
    ListView(
      shrinkWrap: true,
      children: [
        FutureBuilder(
            future: _posts,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Column(
                  children: [
                    listcacheUI(),
                    Row(
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(left: 12, top: 5),
                            child:
                                Text('گەڕان بۆ... "${_searchController.text}"',
                                    style: GoogleFonts.krub(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ))),
                      ],
                    )
                  ],
                );
              }
              if (snapshot.data.docs.length == 0) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('No posts found!',
                          style: GoogleFonts.alef(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          )),
                    ],
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircleProgressIndicator(),
                );
              }
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    PostModel postModel =
                        PostModel.fromDoc(snapshot.data.docs[index]);
                    return buildPostCard(postModel);
                  });
            }),
      ],
    );
  }
}
