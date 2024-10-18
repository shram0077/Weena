import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weena/Models/ActivityModel.dart';
import 'package:weena/Models/userModel.dart';
import 'package:weena/encryption_decryption/encryption.dart';

buildTitle(ActivityModel activityModel, String username) {
  if (activityModel.activityType == 'following') {
    return Row(
      children: [
        Text('$username ',
            style: GoogleFonts.lato(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        Text(activityModel.activityMessage,
            style: GoogleFonts.lato(fontSize: 14, color: Colors.black))
      ],
    );
  } else if (activityModel.activityType == "liked post") {
    return Row(
      children: [
        Text('$username ',
            style: GoogleFonts.lato(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        Text(activityModel.activityMessage,
            style: GoogleFonts.barlow(
                fontWeight: FontWeight.w600, color: Colors.black)),
      ],
    );
  }
}

buildProfilePicture(UserModell userModel) {
  if (userModel.profilePicture.isEmpty) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset('assets/images/person.png'));
  } else {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl:
            MyEncriptionDecription.decryptWithAESKey(userModel.profilePicture),
        fit: BoxFit.cover,
        width: 46,
        height: 46,
      ),
    );
  }
}
