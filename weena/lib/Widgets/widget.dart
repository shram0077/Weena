import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:weena/APi/apis.dart';
import 'package:weena/Constant/constant.dart';
import 'package:weena/Models/Post.dart';
import 'package:weena/Models/userModel.dart';
import 'package:weena/Screens/Profile/profile.dart';
import 'package:weena/Screens/Upload/createFeed.dart';
import 'package:weena/Widgets/profile_ImagePreview.dart';
import 'package:weena/encryption_decryption/encryption.dart';
import '../Screens/Welcome/welcome.dart';

// CircleProgress
CircleProgressIndicator() {
  return Lottie.asset(
    'assets/animations/loadingAnimation.json',
    height: 40,
    width: 40,
  );
}

loadingProfileContiner() {
  return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        padding: const EdgeInsets.all(0.5),
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: shadowColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 78, 89, 123).withOpacity(0.1),
              spreadRadius: 0.2,
              blurRadius: 0.2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ));
}

backButton(ctx, double size) {
  return IconButton(
    onPressed: () {
      Navigator.pop(ctx);
    },
    icon: Icon(
      Icons.arrow_back_ios_new,
      color: Colors.white,
      size: size,
    ),
  );
}

listcacheUI() {
  return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        child: Container(
          width: 60,
          height: 76,
          decoration: BoxDecoration(
              color: profileBGcolor, borderRadius: BorderRadius.circular(12)),
        ),
      ),
      title: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: profileBGcolor,
        ),
      ));
}

isloadingComments(context) {
  double width = MediaQuery.of(context).size.width;

  return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {},
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: unColor,
            ),
          ),
          GestureDetector(
            onLongPress: () {},
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(15)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          Container(
                            width: 55,
                            height: 20,
                            decoration: BoxDecoration(
                                color: unColor,
                                borderRadius: BorderRadius.circular(5)),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: 45,
                            height: 20,
                            decoration: BoxDecoration(
                                color: unColor,
                                borderRadius: BorderRadius.circular(5)),
                          ),
                        ],
                      )),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    color: const Color.fromARGB(255, 191, 191, 191)
                        .withOpacity(.3),
                    height: 0.5,
                    width: width / 1.5,
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Container(
                    width: width / 1.5,
                    height: 28,
                    decoration: BoxDecoration(
                        color: unColor, borderRadius: BorderRadius.circular(5)),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 35,
                        height: 20,
                        decoration: BoxDecoration(
                            color: unColor,
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 35,
                        height: 20,
                        decoration: BoxDecoration(
                            color: unColor,
                            borderRadius: BorderRadius.circular(5)),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
          ),
        ],
      ));
}

userNameProfile(UserModell userModell) {
  return Padding(
    padding: const EdgeInsets.only(top: 0.5, left: 5, bottom: 1.5),
    child: Text(
      "@${userModell.username}",
      style: GoogleFonts.barlow(
          fontWeight: FontWeight.w600, fontSize: 16, color: appBarColor),
    ),
  );
}

displayName(UserModell userModell) {
  return Padding(
    padding: const EdgeInsets.only(top: 10.0, left: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              userModell.name,
              style: GoogleFonts.roboto(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: appBarColor),
            ),
            const SizedBox(
              width: 1,
            ),
            userModell.verification
                ? verfiedBadge(
                    23,
                    23,
                  )
                : const SizedBox(),
            userModell.admin
                ? adminBadge(
                    20,
                    20,
                  )
                : const SizedBox(),
            const SizedBox(
              width: 2,
            ),
          ],
        ),
      ],
    ),
  );
}

videoCard(
  PostModel postModel,
  context,
  String currentVideoId,
) {
  return StreamBuilder(
      stream: usersRef.doc(postModel.userId).snapshots(),
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
        return postModel.postuid == currentVideoId
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(
                    left: 5.0, right: 5, top: 0, bottom: 7),
                child: Container(
                  decoration: BoxDecoration(
                      color: shadowColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6)),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 310,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6)),
                              boxShadow: [
                                BoxShadow(
                                  color: shadowColor.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 2,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6)),
                              child: CachedNetworkImage(
                                imageUrl: postModel.thumbnail,
                                fit: BoxFit.fitHeight,
                                width: double.infinity,
                                height: 310,
                              ),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: ProfileScreen(
                                            currentUserId: APi.myid,
                                            visitedUserId: postModel.userId,
                                            userModel: userModel,
                                          )));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(1),
                                  height: 38,
                                  width: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: shadowColor.withOpacity(0.1),
                                        spreadRadius: 2,
                                        blurRadius: 2,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: CachedNetworkImage(
                                      imageUrl: MyEncriptionDecription
                                          .decryptWithAESKey(
                                              userModel.profilePicture),
                                      fit: BoxFit.cover,
                                      width: 38,
                                      height: 38,
                                    ),
                                  ),
                                )),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      postModel.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.barlow(
                                          color: whiteColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      postModel.description,
                                      maxLines: 2,
                                      textDirection: TextDirection.rtl,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.barlow(
                                          color: shadowColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            postModel.verified
                                ? const Icon(
                                    Icons.verified,
                                    size: 20.0,
                                    color: moviePageColor,
                                  )
                                : const SizedBox()
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
      });
}

adminBadge(double height, double width) {
  return Lottie.asset(
    'assets/animations/admin.json',
    height: height,
    width: width,
  );
}

verfiedBadge(double height, double width) {
  return Lottie.asset(
    'assets/animations/qzcSCXoIxd.json',
    height: height,
    width: width,
  );
}

sayHi(double height, double width) {
  return Lottie.asset(
    'assets/animations/Sayhi.json',
    height: height,
    width: width,
  );
}

verfiedBadgeForPost(double height, double width) {
  return Lottie.asset(
    'assets/animations/0v95pSZ8uL.json',
    height: height,
    width: width,
  );
}

followingandFollowers(
  int followingCount,
  int followersCount,
) {
  return Padding(
    padding: const EdgeInsets.only(top: 0.0, bottom: 5.0, left: 5),
    child: Row(
      children: [
        Text(
          '$followingCount Following'.tr,
          style: GoogleFonts.barlow(
            fontSize: 17,
            color: appBarColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 1,
          height: 11,
          color: Colors.grey.shade400,
        ),
        const SizedBox(width: 6),
        Text(
          '$followersCount Followers'.tr,
          style: GoogleFonts.barlow(
            fontSize: 17,
            color: appBarColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

bio(UserModell userModell, context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 3.0),
        child: Container(
          padding: const EdgeInsets.only(top: 2, bottom: 0),
          width: MediaQuery.of(context).size.width * 0.9,
          child: Linkify(
            onOpen: (link) async {
              if (await canLaunch(link.url)) {
                await launch(link.url);
              } else {
                throw 'Could not launch $link';
              }
            },
            linkStyle: GoogleFonts.barlow(
                color: textBlueColor,
                fontWeight: FontWeight.w500,
                fontSize: 15),
            text: userModell.bio,
            style: GoogleFonts.barlow(
                color: const Color.fromARGB(255, 131, 130, 130),
                fontWeight: FontWeight.w400,
                fontSize: 15),
          ),
        ),
      ),
    ],
  );
}

profilelocation(UserModell userModell, context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      userModell.country.isNotEmpty
          ? Row(
              children: [
                const Icon(
                  FlutterIcons.location_pin_ent,
                  size: 15,
                  color: Color.fromARGB(255, 144, 144, 144),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 1, bottom: 3),
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Text(
                    userModell.cityorTown,
                    style: GoogleFonts.roboto(
                        color: const Color.fromARGB(255, 144, 144, 144),
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
              ],
            )
          : const SizedBox()
    ],
  );
}

normalAvatar(
  UserModell userModel,
  context,
  String currentUserId,
  String visitedUserId,
  key,
  double height,
  double width,
  double raduis,
) {
  return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft,
                child: ProfileImagePreview(
                  currentUserId: currentUserId,
                  visitedUserId: visitedUserId,
                  URLPicture: userModel.profilePicture,
                )));
      },
      child: Container(
        padding: const EdgeInsets.all(1),
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 190, 190, 190),
          borderRadius: BorderRadius.circular(raduis),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 168, 58, 58).withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(raduis),
          child: userModel.profilePicture.isEmpty
              ? CachedNetworkImage(
                  imageUrl:
                      "https://firebasestorage.googleapis.com/v0/b/the-movies-and-drama.appspot.com/o/profilePicture%2FprofilePicture%2Fusers%2FuserProfile_BRLZNE7kWjbNy9bNzwsRU6SNdTF2.jpg?alt=media&token=394df7e8-6493-492d-a23b-32f411c014d4",
                  fit: BoxFit.cover,
                  width: width,
                  height: height,
                )
              : CachedNetworkImage(
                  imageUrl: MyEncriptionDecription.decryptWithAESKey(
                      userModel.profilePicture),
                  fit: BoxFit.cover,
                  width: width,
                  height: height,
                ),
        ),
      ));
}

loadinfAlert(context) {
  return showDialog(
      // The user CANNOT close this dialog  by pressing outsite it
      barrierDismissible: true,
      context: context,
      builder: (_) {
        return Container(
          width: 130,
          height: 150,
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: CircleProgressIndicator(),
                )),
          ),
        );
      });
}

loadingCard() {
  return Center(
      child: Padding(
    padding: const EdgeInsets.only(left: 10),
    child: Container(
      width: 130,
      height: 190,
      decoration: BoxDecoration(
          color: profileBGcolor, borderRadius: BorderRadius.circular(12)),
    ),
  ));
}

socialMediaButton(Color color, IconData icon) {
  return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Icon(
        icon,
        color: Colors.white,
      ));
}

text(String text, Color color, double size, FontWeight fontWeight,
    TextDirection textDirection) {
  return Text(
    text.tr,
    textDirection: textDirection,
    style: TextStyle(
        fontFamily: 'Sirwan',
        color: color,
        fontSize: size,
        fontWeight: fontWeight),
  );
}

Widget buildAds(String admIMG, String onClickLink) {
  return GestureDetector(
    onTap: () async {
      var url = onClickLink;
      if (onClickLink.isEmail) {
        print('OnClickLink is Empty');
      } else {
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          print('Could not launch $url');
        }
      }
    },
    child: Container(
      height: 100,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          image: DecorationImage(
              image: CachedNetworkImageProvider(
                admIMG,
              ),
              fit: BoxFit.contain)),
    ),
  );
}

final ImagePicker imgpicker = ImagePicker();
List<XFile>? imagefiles;
pickImages(ctx, currentUserId) async {
  try {
    var pickedfiles = await imgpicker.pickMultiImage();
    //you can use ImageCourse.camera for Camera capture
    imagefiles = pickedfiles;
    Navigator.push(
        ctx,
        PageTransition(
            type: PageTransitionType.fade,
            child: CreateFeed(
              currentUserId: currentUserId,
              imagefiles: pickedfiles,
            )));
  } catch (e) {
    print("error while picking file.");
  }
}

Widget buildCreateButton(context, String currentUserId) {
  return Padding(
    padding: const EdgeInsets.only(right: 10.0),
    child: GestureDetector(
      onTap: () {
        pickImages(context, currentUserId);
      },
      child: Container(
        padding: const EdgeInsets.only(top: 4, bottom: 4, right: 10, left: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: moviePageColor,
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Center(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              CupertinoIcons.plus_rectangle_fill_on_rectangle_fill,
              color: whiteColor,
              size: 19,
            ),
            const SizedBox(
              width: 5,
            ),
            text('دروستکردن', whiteColor, 15, FontWeight.w500,
                TextDirection.rtl),
          ],
        )),
      ),
    ),
  );
}

Widget shouldbeSignedup(ctx, bool isViewFeeds) {
  return Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 50,
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 6, bottom: 6),
            child: Lottie.asset(
              'assets/animations/Animation-SignUp.json',
              height: 180,
              width: double.infinity,
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        text(".پێویستە کرداری چوونەژوورەوەت ئەنجام دابێت", appBarColor, 20,
            FontWeight.normal, TextDirection.ltr),
        const SizedBox(
          height: 25,
        ),
        MaterialButton(
          minWidth: 300,
          height: 50,
          onPressed: () {
            Navigator.push(
                ctx,
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: const WelcomeScreen(
                      isSkiped: true,
                    )));
          },
          color: moviePageColor.withOpacity(0.9),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Text("Signup or Sign In".tr,
              style: GoogleFonts.lato(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: whiteColor)),
        ),
      ],
    ),
  );
}
