import 'package:cached_network_image/cached_network_image.dart';
import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Models/userModel.dart';
import 'package:weena_latest/Services/DatabaseServices.dart';
import 'package:weena_latest/Widgets/widget.dart';
import 'package:weena_latest/encryption_decryption/encryption.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BuildTile extends StatefulWidget {
  const BuildTile(
      {Key? key,
      required this.userId,
      required this.blockedat,
      required this.currentUserId})
      : super(key: key);
  final String userId;
  final Timestamp blockedat;
  final String currentUserId;

  @override
  State<BuildTile> createState() => _BuildTileState();
}

class _BuildTileState extends State<BuildTile> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: usersRef.doc(widget.userId).snapshots(),
        builder: ((BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.only(top: 300.0),
              child: Center(child: CircleProgressIndicator()),
            );
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
          return ListTile(
            title: Text(
              userModel.username,
              style: GoogleFonts.lato(color: Colors.black),
            ),
            leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                    MyEncriptionDecription.decryptWithAESKey(
                        userModel.profilePicture))),
            subtitle: Text(
              DateFormat.yMMMMEEEEd().format(
                widget.blockedat.toDate(),
              ),
              style: GoogleFonts.barlow(color: Colors.black),
            ),
            trailing: IconButton(
                onPressed: () {
                  try {
                    DatabaseServices.unblockUser(
                        widget.currentUserId, widget.userId);
                    setState(() {});
                  } catch (e) {
                    Fluttertoast.showToast(msg: '$e');
                  }
                },
                icon: const Icon(
                  Icons.close_outlined,
                  size: 27,
                  color: Colors.black,
                )),
          );
        }));
  }
}
