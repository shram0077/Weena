import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Models/Post.dart';

buildItemsContainer(
  IconData icon,
  String txt,
  PostModel postModel,
  String currentUserId,
  BuildContext context,
) {
  return InkWell(
    onTap: () {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color.fromARGB(255, 30, 29, 29),
            title: Center(
              child: Text(
                'ئایا دڵنیای لە ناردنی ڕیپۆرتەکەت؟'.tr,
                style: GoogleFonts.barlow(color: Colors.white),
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  'NO'.tr,
                  style: GoogleFonts.barlow(color: Colors.white),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(
                  'YES'.tr,
                  style: GoogleFonts.barlow(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  try {
                    await movieReportsRef
                        .doc(postModel.postuid)
                        .collection('Reports')
                        .doc(currentUserId)
                        .set({
                      'postId': postModel.postuid,
                      'reportedBy': currentUserId,
                      'messageReport': txt,
                      'Timestamp': Timestamp.now(),
                    });

                    Fluttertoast.showToast(
                      msg: 'نێردرا، سووپاس',
                      backgroundColor: Colors.green,
                      textColor: whiteColor,
                    );

                    await movieReportsRef
                        .doc(postModel.postuid)
                        .set({'PostId': postModel.postuid});

                    Navigator.of(context).pop();
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: 'هەڵەیەک ڕویدا',
                      backgroundColor: Colors.red,
                      textColor: whiteColor,
                    );
                  }
                },
              ),
            ],
          );
        },
      );
    },
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 20, color: whiteColor),
          Text(
            txt,
            style: GoogleFonts.barlow(
              color: whiteColor,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
