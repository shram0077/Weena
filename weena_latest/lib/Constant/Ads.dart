import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:weena_latest/Constant/constant.dart';
import 'package:weena_latest/Screens/MoviePage/VideoPlayer.dart';

class AdManager {
  static Future<void> loadUnityAd(plcID) async {
    await UnityAds.load(
      placementId: plcID,
      onComplete: (placementId) => print('Load Complete $placementId'),
      onFailed: (placementId, error, message) =>
          print('Load Failed $placementId: $error $message'),
    );
  }

  static Future<void> showVideoAd(ctx, user, userModel, postModel,
      currentUserId, comments, isFromEpisode, episodeLink, isDirectLink) async {
    await UnityAds.showVideoAd(
        placementId: placementId,
        onStart: (placementId) => print('Video Ad $placementId started'),
        onClick: (placementId) => print('Video Ad $placementId click'),
        onSkipped: (placementId) {
          if (isFromEpisode) {
            Navigator.push(
                ctx,
                PageTransition(
                    type: PageTransitionType.fade,
                    child: VideoPlayer(
                      episodeLink: episodeLink,
                      isFromEpisode: true,
                      isAnonymous: user,
                      userModell: userModel,
                      postModel: postModel,
                      currentUserId: currentUserId,
                      commentCount: comments,
                      isDirectLink: isDirectLink,
                    )));
          } else {
            Navigator.push(
                ctx,
                PageTransition(
                    type: PageTransitionType.fade,
                    child: VideoPlayer(
                      isDirectLink: isDirectLink,
                      isFromEpisode: false,
                      isAnonymous: user,
                      userModell: userModel,
                      postModel: postModel,
                      currentUserId: currentUserId!,
                      commentCount: comments,
                    )));
          }
        },
        onComplete: (ct) {
          if (isFromEpisode) {
            Navigator.push(
                ctx,
                PageTransition(
                    type: PageTransitionType.fade,
                    child: VideoPlayer(
                      isDirectLink: isDirectLink,
                      episodeLink: episodeLink,
                      isFromEpisode: true,
                      isAnonymous: user,
                      userModell: userModel,
                      postModel: postModel,
                      currentUserId: currentUserId,
                      commentCount: comments,
                    )));
          } else {
            Navigator.push(
                ctx,
                PageTransition(
                    type: PageTransitionType.fade,
                    child: VideoPlayer(
                      isDirectLink: isDirectLink,
                      isFromEpisode: false,
                      isAnonymous: user,
                      userModell: userModel,
                      postModel: postModel,
                      currentUserId: currentUserId!,
                      commentCount: comments,
                    )));
          }
        },
        onFailed: (placementId, error, message) => {
              if (isFromEpisode)
                {
                  Navigator.push(
                      ctx,
                      PageTransition(
                          type: PageTransitionType.fade,
                          child: VideoPlayer(
                            isDirectLink: isDirectLink,
                            episodeLink: episodeLink,
                            isFromEpisode: true,
                            isAnonymous: user,
                            userModell: userModel,
                            postModel: postModel,
                            currentUserId: currentUserId,
                            commentCount: comments,
                          )))
                }
              else
                {
                  Navigator.push(
                      ctx,
                      PageTransition(
                          type: PageTransitionType.fade,
                          child: VideoPlayer(
                            isDirectLink: isDirectLink,
                            isFromEpisode: false,
                            isAnonymous: user,
                            userModell: userModel,
                            postModel: postModel,
                            currentUserId: currentUserId!,
                            commentCount: comments,
                          )))
                }
            });
  }
}
