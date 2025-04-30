import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Screens/Profile/Settings/Blocked/buildTile.dart';
import 'package:weena_latest/Widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class BlockedUsers extends StatefulWidget {
  final String currentUserId;

  const BlockedUsers({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<BlockedUsers> createState() => _BlockedUsersState();
}

class _BlockedUsersState extends State<BlockedUsers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.2,
          title: text("Blocked", Colors.black, 18, FontWeight.normal,
              TextDirection.rtl),
          backgroundColor: whiteColor,
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
              )),
        ),
        body: StreamBuilder(
            stream: blockedRef
                .doc(widget.currentUserId)
                .collection('Block')
                .snapshots(),
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
              } else if (snapshot.hasError) {
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
              } else if (snapshot.data.docs.length == 0) {
                return Center(
                  child: Text(
                    'No one has been blocked.'.tr,
                    style: GoogleFonts.barlow(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                );
              }
              return ListView.builder(
                  shrinkWrap: false,
                  primary: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return BuildTile(
                      currentUserId: widget.currentUserId,
                      blockedat: snapshot.data.docs[index]['Timestamp'],
                      userId: snapshot.data.docs[index]['BlockedUser'],
                    );
                  });
            }));
  }
}
