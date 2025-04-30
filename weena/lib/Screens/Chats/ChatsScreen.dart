import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';
import 'package:weena/APi/apis.dart';
import 'package:weena/Constant/constant.dart';
import 'package:weena/Models/userModel.dart';
import 'package:weena/Screens/Chats/ChatWidget.dart';
import 'package:weena/Screens/Profile/profile.dart';
import 'package:weena/Widgets/widget.dart';
import 'package:weena/encryption_decryption/encryption.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String visitedUserId;
  final String profilePicture;
  final String name;
  final Timestamp lastSeen;
  final String pushToken;
  final UserModell userModell;
  const ChatScreen(
      {super.key,
      required this.currentUserId,
      required this.visitedUserId,
      required this.profilePicture,
      required this.lastSeen,
      required this.name,
      required this.userModell,
      required this.pushToken});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var key;
  bool _isSending = false;
  final messageController = TextEditingController();
  ImagePicker image = ImagePicker();
  File? file;
  bool emojiShowing = false;
  // Pick Image
  pickImage() async {
    final XFile? img = await image.pickImage(source: ImageSource.gallery);
    setState(() {
      if (file == null) {
        file = File(img!.path);
      } else {}
    });
    if (file == null) {
      print('file is empty');
    } else {
      setState(() {
        uploadChatImage();
      });
    }
  }

  final FirebaseAuth auth = FirebaseAuth.instance;

// UploadImageChat
  uploadChatImage() async {
    var chatId = const Uuid().v4();

    UploadTask uploadTask =
        storageRef.child('chatImages/images/$chatId.jpg').putFile(file!);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    setState(() {
      _isSending = true;
      // CurrentUserId
      addchatsRef
          .doc(widget.currentUserId)
          .collection('Add')
          .doc(widget.visitedUserId)
          .update({
        'lastMessage Timestamp': Timestamp.now(),
        'lastMessage text': 'Send a photo',
      });
      // VisitedUserId

      addchatsRef
          .doc(widget.visitedUserId)
          .collection('Add')
          .doc(widget.currentUserId)
          .update({
        'lastMessage Timestamp': Timestamp.now(),
        'lastMessage text': 'Send a photo',
      });

      // SendMessage

// SetUp CurrentUserId
      chatsRef
          .doc(widget.currentUserId)
          .collection('Chat with')
          .doc(widget.visitedUserId)
          .collection('Messages')
          .doc(chatId)
          .set({
        'TextMessage': '',
        'SenderId': widget.currentUserId,
        'RecevierId': widget.visitedUserId,
        'Timestamp': Timestamp.now(),
        'SendByMy': true,
        'Image': downloadUrl,
        'isHide': false,
        'uuidchat': chatId
      }).then((value) {
        // SetUp VisitedUserId

        chatsRef
            .doc(widget.visitedUserId)
            .collection('Chat with')
            .doc(widget.currentUserId)
            .collection('Messages')
            .doc(chatId)
            .set({
          'TextMessage': '',
          'SenderId': widget.currentUserId,
          'RecevierId': widget.visitedUserId,
          'Timestamp': Timestamp.now(),
          'SendByMy': false,
          'Image': downloadUrl,
          'isHide': false,
          'uuidchat': chatId
        }).whenComplete(() => APi.sendMessagePushNotification(
                "وێنەیەکی بۆ ناردیت", widget.pushToken));
        setState(() {
          messageController.clear();
          file = null;
          _isSending = false;
          downloadUrl.removeAllWhitespace;
        });
      });
    });
    return downloadUrl;
  }

  static Future<XFile> compressImage(String photoId, File image) async {
    final tempDirection = await getTemporaryDirectory();
    final path = tempDirection.path;
    XFile? compressedImage = await FlutterImageCompress.compressAndGetFile(
        image.absolute.path, '$path/img_$photoId.jpg',
        quality: 85);

    return compressedImage!;
  }

  squareProfilePicture(UserModell user, double height, double width,
      double raduis, bool isActive) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: ProfileScreen(
                    currentUserId: widget.currentUserId,
                    userModel: user,
                    visitedUserId: user.id,
                  )));
        },
        child: Container(
          padding: const EdgeInsets.all(1),
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.white,
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
          child: user.profilePicture.isEmpty
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

  void readTheMessage() async {
    await addchatsRef
        .doc(widget.userModell.id)
        .collection('Add')
        .doc(widget.currentUserId)
        .update({"isRead": true});
    await addchatsRef
        .doc(widget.currentUserId)
        .collection('Add')
        .doc(widget.userModell.id)
        .update({"isRead": true});
  }

  bool isNow = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readTheMessage();
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (timeago.format(widget.userModell.activeTime.toDate()).toString() ==
          "a moment ago") {
        setState(() {
          isNow = true;
        });
      } else {
        setState(() {
          isNow = false;
        });
      }
    });
    loadUpdate();
  }

  bool sendPictures = false;
  void loadUpdate() async {
    QuerySnapshot collection =
        await FirebaseFirestore.instance.collection("Update's").get();
    var random = Random().nextInt(collection.docs.length);
    DocumentSnapshot randomDoc = collection.docs[random];
    setState(() {
      sendPictures = randomDoc["SendPictures"];
    });
  }

  @override
  Widget build(BuildContext context) {
    const kDefaultPadding = 20.0;
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        actions: [
          Padding(
              padding:
                  const EdgeInsets.only(top: 5, bottom: 5, right: 7, left: 5),
              child: squareProfilePicture(widget.userModell, 60, 50, 8, false))
        ],
        elevation: 0.2,
        backgroundColor: whiteColor,
        leading: backButton(context, 20),
        centerTitle: true,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: ProfileScreen(
                      userModel: widget.userModell,
                      currentUserId: widget.currentUserId,
                      visitedUserId: widget.visitedUserId,
                      key: key,
                    )));
          },
          child: Column(
            children: [
              text(widget.name, Colors.black, 16, FontWeight.normal,
                  TextDirection.ltr),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 5),
                child: text(
                    timeago.format(widget.userModell.activeTime.toDate(),
                        allowFromNow: true),
                    isNow ? Colors.green : Colors.grey,
                    10,
                    FontWeight.w100,
                    TextDirection.ltr),
              )
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            child: Expanded(
              child: StreamBuilder(
                stream: chatsRef
                    .doc(widget.currentUserId)
                    .collection('Chat with')
                    .doc(widget.visitedUserId)
                    .collection('Messages')
                    .orderBy('Timestamp', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.docs.length < 1) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: sayHi(110, 110),
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                                left: 7, right: 7, top: 0, bottom: 0),
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 138, 125, 2)
                                    .withOpacity(0.9),
                                borderRadius: BorderRadius.circular(4)),
                            child: text("هیچ پەیامێک نییە هێشتا.", whiteColor,
                                14, FontWeight.normal, TextDirection.rtl),
                          )
                        ],
                      );
                    }
                    return ListView.builder(
                        shrinkWrap: true,
                        reverse: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          bool isMy = snapshot.data.docs[index]['SenderId'] ==
                              widget.currentUserId;
                          return ChatWidget(
                            textMessage: snapshot.data.docs[index]
                                ['TextMessage'],
                            loading: _isSending,
                            image: snapshot.data.docs[index]['Image'],
                            timestamp: snapshot.data.docs[index]['Timestamp'],
                            isSendByMy: isMy,
                            recevierId: snapshot.data.docs[index]['RecevierId'],
                            senderId: snapshot.data.docs[index]['SenderId'],
                            isSending: _isSending,
                            profilePicture: widget.profilePicture,
                            name: widget.name,
                            currentUserId: widget.currentUserId,
                            visitedUserId: widget.visitedUserId,
                            chatid: snapshot.data.docs[index]['uuidchat'],
                          );
                        });
                  }

                  return Center(
                    child: CircleProgressIndicator(),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding,
              vertical: kDefaultPadding / 2,
            ),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 238, 234, 234),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(3, 2),
                  blurRadius: 2,
                  color: const Color.fromARGB(255, 58, 58, 58).withOpacity(0.9),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kDefaultPadding * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 219, 218, 218),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          sendPictures
                              ? GestureDetector(
                                  onTap: () {
                                    pickImage();
                                  },
                                  child: const Icon(CupertinoIcons.photo_camera,
                                      color: shadowColor))
                              : const SizedBox(),
                          sendPictures
                              ? const SizedBox(width: kDefaultPadding)
                              : const SizedBox(),
                          const SizedBox(width: kDefaultPadding / 4),
                          Expanded(
                            child: TextField(
                              textDirection: TextDirection.rtl,
                              enabled: _isSending ? false : true,
                              onTap: () {},
                              onChanged: (value) {
                                setState(() {
                                  messageController;
                                });
                              },
                              onSubmitted: (value) {
                                if (value.isEmpty) {
                                } else {
                                  sendMessage();
                                }
                              },
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              cursorColor: Colors.amber,
                              controller: messageController,
                              decoration: const InputDecoration(
                                hintTextDirection: TextDirection.rtl,
                                border: InputBorder.none,
                                hintText: "شتێک بنووسە...",
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage() async {
    setState(() {
      _isSending = true;
    });
    var chatId = const Uuid().v4();

    String message = messageController.text;
    if (message.isEmpty) {
      print('TextFiled isEmpty');
    } else if (message.isNotEmpty) {
      // CurrentUserId
      await addchatsRef
          .doc(widget.currentUserId)
          .collection('Add')
          .doc(widget.visitedUserId)
          .update({
        'lastMessage Timestamp': Timestamp.now(),
        'lastMessage text': MyEncriptionDecription.encryptWithAESKey(message),
      });
      // VisitedUserId
      await addchatsRef
          .doc(widget.visitedUserId)
          .collection('Add')
          .doc(widget.currentUserId)
          .update({
        'lastMessage Timestamp': Timestamp.now(),
        'lastMessage text': MyEncriptionDecription.encryptWithAESKey(message),
      });

      // SendMessage

// SetUp CurrentUserId
      await chatsRef
          .doc(widget.currentUserId)
          .collection('Chat with')
          .doc(widget.visitedUserId)
          .collection('Messages')
          .doc(chatId)
          .set({
        'TextMessage': MyEncriptionDecription.encryptWithAESKey(message),
        'SenderId': widget.currentUserId,
        'RecevierId': widget.visitedUserId,
        'Timestamp': Timestamp.now(),
        'SendByMy': true,
        'Image': '',
        'isHide': false,
        'uuidchat': chatId
      }).then((value) async {
        // SetUp VisitedUserId

        await chatsRef
            .doc(widget.visitedUserId)
            .collection('Chat with')
            .doc(widget.currentUserId)
            .collection('Messages')
            .doc(chatId)
            .set({
          'TextMessage': MyEncriptionDecription.encryptWithAESKey(message),
          'SenderId': widget.currentUserId,
          'RecevierId': widget.visitedUserId,
          'Timestamp': Timestamp.now(),
          'SendByMy': false,
          'Image': '',
          'isHide': false,
          'uuidchat': chatId
        }).whenComplete(() => APi.sendMessagePushNotification(
                message.isNotEmpty ? message : "وینە", widget.pushToken));

        setState(() {
          messageController.clear();
          // ignore: unnecessary_null_comparison
          messageController == null;
          _isSending = false;
        });
        await addchatsRef
            .doc(widget.visitedUserId)
            .collection('Add')
            .doc(widget.currentUserId)
            .update({"isRead": false});
      });
    }
  }
}
