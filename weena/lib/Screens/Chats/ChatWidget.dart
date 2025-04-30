import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weena/Screens/Chats/ViewImageChat.dart';
import 'package:weena/encryption_decryption/encryption.dart';

import '../../Constant/constant.dart';

class ChatWidget extends StatefulWidget {
  final String currentUserId;
  final String visitedUserId;
  final String textMessage;
  final String image;
  final Timestamp timestamp;
  final bool isSendByMy;
  final String recevierId;
  final String senderId;
  final bool isSending;
  final String profilePicture;
  final String name;
  final bool loading;
  final String chatid;
  const ChatWidget(
      {super.key,
      required this.textMessage,
      required this.loading,
      required this.image,
      required this.timestamp,
      required this.isSendByMy,
      required this.recevierId,
      required this.senderId,
      required this.isSending,
      required this.profilePicture,
      required this.name,
      required this.currentUserId,
      required this.visitedUserId,
      required this.chatid});
  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  Future<void> deleteMessage(String messageId) async {
    final chatpicturestorage =
        storageRef.child("chatImages/images/$messageId.jpg");

    await chatsRef
        .doc(widget.visitedUserId)
        .collection('Chat with')
        .doc(widget.currentUserId)
        .collection('Messages')
        .doc(widget.chatid)
        .delete()
        .whenComplete(() => chatsRef
            .doc(widget.currentUserId)
            .collection('Chat with')
            .doc(widget.visitedUserId)
            .collection('Messages')
            .doc(widget.chatid)
            .delete());

// CurrentUser
    await addchatsRef
        .doc(widget.currentUserId)
        .collection('Add')
        .doc(widget.visitedUserId)
        .update({
      'lastMessage Timestamp': Timestamp.now(),
      'lastMessage text':
          MyEncriptionDecription.encryptWithAESKey("تۆنامەکەت سڕیەوە'"),
    });
    // VisitedUserId
    await addchatsRef
        .doc(widget.visitedUserId)
        .collection('Add')
        .doc(widget.currentUserId)
        .update({
      'lastMessage Timestamp': Timestamp.now(),
      'lastMessage text': MyEncriptionDecription.encryptWithAESKey(
          "${widget.name} نامەکەی سڕیەوە"),
    });

    if (widget.textMessage.isNotEmpty) {
    } else {
      chatpicturestorage.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(DateFormat.Hm().format(widget.timestamp.toDate()),
            style: GoogleFonts.lato(
                fontSize: 12, color: const Color.fromARGB(255, 80, 80, 80))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
          child: Row(
            mainAxisAlignment: widget.isSendByMy
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Container(
                child: GestureDetector(
                  onLongPress: () {
                    showMessageBottom();
                  },
                  child: widget.textMessage.isEmpty
                      ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ViewImage(
                                        image: widget.image,
                                        isloading: widget.loading,
                                        timeago: widget.timestamp,
                                      )),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: moviePageColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                        widget.image),
                                    fit: BoxFit.cover)),
                            width: 200,
                            height: 250,
                          ),
                        )
                      : Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.80,
                          ),
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: moviePageColor,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 220, 145, 145)
                                    .withOpacity(0.4),
                                spreadRadius: 2,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Linkify(
                              onOpen: (link) async {
                                if (await canLaunch(link.url)) {
                                  await launch(link.url);
                                } else {
                                  throw 'Could not launch $link';
                                }
                              },
                              linkStyle: GoogleFonts.barlow(
                                  fontSize: 16.0, color: errorColor),
                              text: MyEncriptionDecription.decryptWithAESKey(
                                  widget.textMessage),
                              style: GoogleFonts.barlow(
                                fontSize: 16.0,
                                color: widget.isSending
                                    ? Colors.black54
                                    : Colors.white,
                              )),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  showMessageBottom() {
    return showModalBottomSheet(
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
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.isSendByMy ? 'من' : widget.name,
                          style: GoogleFonts.lato(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: widget.isSendByMy
                                  ? Colors.grey
                                  : Colors.black)),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0, bottom: 8),
                        child: Text(
                            DateFormat.yMMMMEEEEd()
                                .format(widget.timestamp.toDate()),
                            style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 5),
                  child: Column(
                    children: [
                      widget.textMessage.isEmpty
                          ? const SizedBox()
                          : ReadMoreText(
                              MyEncriptionDecription.decryptWithAESKey(
                                  widget.textMessage),
                              style: GoogleFonts.lato(),
                              trimLines: 3,
                              colorClickableText:
                                  const Color.fromARGB(255, 202, 17, 17),
                              trimMode: TrimMode.Line,
                              trimCollapsedText: 'Show more'.tr,
                              trimExpandedText: '   Show less'.tr,
                              moreStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color.fromARGB(255, 33, 67, 218),
                              )),
                    ],
                  ),
                ),
                widget.isSendByMy
                    ? ListTile(
                        onTap: () {
                          deleteMessage(widget.chatid);
                        },
                        leading: const Icon(CupertinoIcons.trash),
                        title: Text('Delete'.tr,
                            style: GoogleFonts.abel(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            )),
                      )
                    : const SizedBox(),
                widget.textMessage.isNotEmpty
                    ? ListTile(
                        onTap: () {
                          FlutterClipboard.copy(
                                  MyEncriptionDecription.decryptWithAESKey(
                                      widget.textMessage))
                              .then((value) {
                            setState(() {
                              Fluttertoast.showToast(
                                  msg: 'Copied'.tr,
                                  backgroundColor:
                                      const Color.fromARGB(255, 135, 135, 135));
                              Navigator.pop(context);
                            });
                          });
                        },
                        leading: const Icon(CupertinoIcons.doc_on_clipboard),
                        title: Text('Copy'.tr,
                            style: GoogleFonts.abel(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            )),
                      )
                    : ListTile(
                        onTap: () {},
                        leading: const Icon(CupertinoIcons.download_circle),
                        title: Text('Save'.tr,
                            style: GoogleFonts.abel(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            )),
                      )
              ],
            ),
          );
        });
  }
}
