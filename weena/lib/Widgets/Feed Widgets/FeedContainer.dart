import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weena/Constant/constant.dart';
import 'package:weena/Models/userModel.dart';
import 'package:weena/Screens/Profile/profile.dart';
import 'package:weena/Services/DatabaseServices.dart';
import 'package:weena/Widgets/Feed%20Widgets/likeButton.dart';
import 'package:weena/Widgets/widget.dart';
import 'package:weena/encryption_decryption/encryption.dart';
import 'RefeedButton.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

class FeedContainer extends StatefulWidget {
  final UserModell userModell;
  final String description;
  final List pictures;
  final int likes;
  final int refeed;
  final Timestamp timestamp;
  final String currentUserId;
  final String ownerId;
  final String postId;
  final bool fromProfile;
  const FeedContainer(
      {super.key,
      required this.userModell,
      required this.description,
      required this.pictures,
      required this.likes,
      required this.refeed,
      required this.timestamp,
      required this.currentUserId,
      required this.ownerId,
      required this.postId,
      required this.fromProfile});

  @override
  State<FeedContainer> createState() => _FeedContainerState();
}

class _FeedContainerState extends State<FeedContainer> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 246, 244, 244),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            widget.fromProfile
                ? normalAvatar(widget.userModell, context, widget.currentUserId,
                    widget.userModell.id, widget.key, 47, 47, 8)
                : GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: ProfileScreen(
                                currentUserId: widget.currentUserId,
                                visitedUserId: widget.ownerId,
                                userModel: widget.userModell,
                              )));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      height: 53,
                      width: 53,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 78, 89, 123)
                                .withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: MyEncriptionDecription.decryptWithAESKey(
                              widget.userModell.profilePicture),
                          fit: BoxFit.cover,
                          width: 53,
                          height: 53,
                        ),
                      ),
                    )),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            if (widget.fromProfile) {
                            } else {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      child: ProfileScreen(
                                        currentUserId: widget.currentUserId,
                                        visitedUserId: widget.ownerId,
                                        userModel: widget.userModell,
                                      )));
                            }
                          },
                          child: Text(
                            widget.userModell.name,
                            style: const TextStyle(
                                color: appBarColor,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          width: 1,
                        ),
                        widget.userModell.verification
                            ? verfiedBadge(20, 20)
                            : const SizedBox(),
                        widget.userModell.admin
                            ? adminBadge(
                                19,
                                19,
                              )
                            : const SizedBox(),
                        const Spacer(),
                        Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text(
                              timeago.format(widget.timestamp.toDate()),
                              style: const TextStyle(color: Colors.grey),
                            )),
                      ],
                    ),
                    widget.description.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(
                              5.0,
                            ),
                            child: SelectableLinkify(
                                onOpen: (link) async {
                                  if (await canLaunch(link.url)) {
                                    await launch(link.url);
                                  } else {
                                    throw 'Could not launch $link';
                                  }
                                },
                                linkStyle: GoogleFonts.barlow(
                                    fontSize: 16.0, color: textBlueColor),
                                text: widget.description,
                                textDirection: TextDirection.rtl,
                                style: GoogleFonts.barlow(
                                    fontSize: 16.0, color: appBarColor)),
                          )
                        : const SizedBox(
                            height: 3,
                          ),
                    widget.pictures.isNotEmpty
                        ? InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.fade,
                                      child: ViewAllPictures(
                                        pictures: widget.pictures,
                                      )));
                            },
                            child: Material(
                              color: appBarColor,
                              borderRadius: BorderRadius.circular(10.0),
                              child: widget.pictures.isEmpty
                                  ? const SizedBox()
                                  : widget.pictures.length > 1
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          child: Container(
                                            width: double.infinity,
                                            height: 250,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image:
                                                        CachedNetworkImageProvider(
                                                      widget.pictures[0],
                                                    ),
                                                    fit: BoxFit.cover)),
                                            child: Center(
                                              child: Container(
                                                width: double.infinity,
                                                height: 250,
                                                decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        159, 40, 39, 39),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                child: Center(
                                                  child: Text(
                                                    "+ وێنەن ${widget.pictures.length.toString()}",
                                                    style: GoogleFonts.barlow(
                                                        color: whiteColor,
                                                        fontSize: 23),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ))
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          child: CachedNetworkImage(
                                            imageUrl: widget.pictures[0],
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                            ),
                          )
                        : const SizedBox(height: 0.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 0.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: LikeButton(
                            profilePicture: widget.userModell.profilePicture,
                            currentUserId: widget.currentUserId,
                            ownerId: widget.ownerId,
                            pictures: widget.pictures,
                            postId: widget.postId,
                          )),
                          Expanded(
                              child: ReFeedButton(
                            refeedCount: widget.refeed,
                            profilePicture: widget.userModell.profilePicture,
                            currentUserId: widget.currentUserId,
                            ownerId: widget.ownerId,
                            pictures: widget.pictures,
                            postId: widget.postId,
                          )),
                          widget.currentUserId == widget.ownerId
                              ? InkWell(
                                  onTap: deleteFeedAlert,
                                  borderRadius: BorderRadius.circular(15),
                                  child: const Icon(
                                    CupertinoIcons.trash,
                                    color: Colors.grey,
                                    size: 20.0,
                                  ),
                                )
                              : const SizedBox()
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  deleteFeedAlert() {
    final feedImagesStorage = storageRef
        .child('Feeds/Feeds OF ${widget.currentUserId}/${widget.postId}.jpg');
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Center(
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.trash,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(
                  width: 3,
                ),
                Text(
                  'دڵنیای لە سڕینەوەی پۆستەکەت؟',
                  style: GoogleFonts.barlow(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              // ignore: sort_child_properties_last
              child: Text(
                'NO'.tr,
                style: GoogleFonts.barlow(color: Colors.white),
              ),
              onPressed: Navigator.of(context).pop,
            ),
            TextButton(
              child: Text(
                'YES'.tr,
                style: GoogleFonts.barlow(
                    color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                feedsRef
                    .doc(widget.currentUserId)
                    .collection('Feeds')
                    .doc(widget.postId)
                    .delete()
                    .whenComplete(() => Navigator.pop(context));
                DatabaseServices.deleteLikesOfPosts(widget.postId);
                DatabaseServices.deleteReefedsOfFeed(widget.postId);
                reefeedsRef.doc(widget.postId).delete();
              },
            )
          ],
        );
      },
    );
  }
}

class ViewAllPictures extends StatefulWidget {
  final List pictures;

  const ViewAllPictures({super.key, required this.pictures});

  @override
  State<ViewAllPictures> createState() => _ViewAllPicturesState();
}

class _ViewAllPicturesState extends State<ViewAllPictures> {
  int activePage = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: appBarColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: backButton(context, 23),
          backgroundColor: appBarColor,
        ),
        body: PhotoViewGallery.builder(
          itemCount: widget.pictures.length,
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(
                widget.pictures[index],
              ),
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          },
          scrollPhysics: const BouncingScrollPhysics(),
          backgroundDecoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: appBarColor,
          ),
          enableRotation: true,
          loadingBuilder: (context, event) => Center(
            child: SizedBox(
              width: 30.0,
              height: 30.0,
              child: CircularProgressIndicator(
                backgroundColor: Colors.orange,
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
              ),
            ),
          ),
        ));
  }
}
