import 'dart:io';
import 'package:h_alert_dialog/h_alert_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weena_latest/Models/ActivityModel.dart';
import 'package:weena_latest/Models/ChatModel.dart';
import 'package:weena_latest/Models/FeedModel.dart';
import 'package:weena_latest/Models/HistoryModel.dart';
import 'package:weena_latest/Models/Post.dart';
import 'package:weena_latest/Models/SeriesModel.dart';
import 'package:weena_latest/Models/linksModel.dart';
import 'package:weena_latest/Models/userModel.dart';
import 'package:weena_latest/Models/CommentModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Constant/constant.dart';

class DatabaseServices {
  // Add View
  static void addView(PostModel postModel, String currentUserId) async {
    await viewsRef
        .doc(postModel.postuid)
        .collection("Views")
        .doc(currentUserId)
        .set({"postuid": postModel.postuid});

    await postsRef
        .doc(postModel.userId)
        .collection('userPosts')
        .doc(postModel.postuid)
        .update({'views': FieldValue.increment(1)})
        .then(
          (value) => moviesRef
              .doc(postModel.postuid)
              .update({'views': FieldValue.increment(1)})
              .then(
                (value) => moviesRef.doc(postModel.postuid).update({
                  'views': FieldValue.increment(1),
                }),
              ),
        );
    print('View has been sent');
  }

  // Set to History
  static void setToHistory(
    PostModel postModel,
    String currentUserId,
    String ownerId,
  ) async {
    await historyViews
        .doc(currentUserId)
        .collection("Viewed")
        .doc(postModel.id)
        .set({
          "postuid": postModel.postuid,
          "Timestamp": Timestamp.now(),
          "OwnerId": ownerId,
        });
  }

  // Get Views
  static Future<int> getViews(PostModel postModel) async {
    QuerySnapshot viewsSnapshot =
        await viewsRef.doc(postModel.postuid).collection('Views').get();
    return viewsSnapshot.docs.length;
  }

  // Get Comments Count
  static Future<int> getCommentsCount(PostModel postModel) async {
    QuerySnapshot commentsSnapshot =
        await commentsRef.doc(postModel.postuid).collection('Comments').get();
    return commentsSnapshot.docs.length;
  }

  // Get Followers
  static Future<int> getFollowers(String userId) async {
    QuerySnapshot followersSnapshot =
        await followersRef.doc(userId).collection('Followers').get();
    return followersSnapshot.docs.length;
  }

  // Update User Display Nname
  static void updateUserDisplayName(UserModell user) {
    usersRef.doc(user.id).update({'name': user.name});
  }

  // Update links
  static void updateLinks(String userId, LinksModel linksModel, ctx) {
    linksRef
        .doc(userId)
        .update({
          "Facebook": linksModel.facebook,
          "Instagram": linksModel.instagram,
          "YouTube": linksModel.youtube,
        })
        .whenComplete(() {
          Fluttertoast.showToast(
            msg: 'خەزنکرا',
            backgroundColor: appcolor,
            textColor: Colors.white,
          );
          Navigator.pop(ctx);
        });
  }

  // Update Country or city
  static void updateCountryorCity(UserModell userModell) {
    usersRef.doc(userModell.id).update({
      'country': userModell.country,
      'cityorTown': userModell.cityorTown,
    });
    print("Result : ${userModell.country}");
  }

  // Update About User
  static void updateAboutUser(UserModell user) {
    usersRef.doc(user.id).update({'bio': user.bio});
  }

  static void uploadVideo(
    String title,
    String description,
    String uuid,
    String videoLink,
    String thumbnailLink,
    String type,
    String currentUserId,
    int episode,
    int series,
    context,
    double imdbRating,
    int likes,
    int views,
    String userid,
    List tags,
    String trailer,
  ) {
    postsRef
        .doc(currentUserId)
        .collection('userPosts')
        .doc(uuid)
        .set({
          "description": description,
          "video": videoLink,
          "Timestamp": Timestamp.now(),
          "postuid": uuid,
          "title": title,
          "type": type,
          "userId": userid,
          "verified": false,
          'thumbnail': thumbnailLink,
          "episode": episode,
          'series': series,
          "tags": tags,
          "trailer": trailer,
          "imdbRating": imdbRating,
          "likes": likes,
          "views": views,
        })
        .then((doc) async {
          QuerySnapshot followerSnapshot =
              await followersRef
                  .doc(currentUserId)
                  .collection('Followers')
                  .get();

          for (var docSnapshot in followerSnapshot.docs) {
            followingPostsRef
                .doc(docSnapshot.id)
                .collection('posts')
                .doc(uuid)
                .set({
                  "description": description,
                  "video": videoLink,
                  "Timestamp": Timestamp.now(),
                  "postuid": uuid,
                  "title": title,
                  "type": type,
                  "userId": userid,
                  "verified": false,
                  'thumbnail': thumbnailLink,
                  "episode": episode,
                  'series': series,
                  "tags": tags,
                  "trailer": trailer,
                  "imdbRating": imdbRating,
                  "likes": likes,
                  "views": views,
                });
          }
        })
        .whenComplete(
          () => moviesRef.doc(uuid).set({
            "description": description,
            "video": videoLink,
            "Timestamp": Timestamp.now(),
            "postuid": uuid,
            "title": title,
            "type": type,
            "userId": userid,
            "verified": false,
            'thumbnail': thumbnailLink,
            "episode": episode,
            'series': series,
            "tags": tags,
            "trailer": trailer,
            "imdbRating": imdbRating,
            "likes": likes,
            "views": views,
          }),
        )
        .whenComplete(
          () => Fluttertoast.showToast(
            msg: 'succs',
            backgroundColor: Colors.green,
          ),
        )
        .then((value) => Navigator.pop(context));
  }

  static void likeComment(PostModel postModel, String currentUserId) async {
    commentsRef.doc(postModel.postuid).set({"likes": currentUserId});
  }

  // Add comment
  static void addComment(
    PostModel postModel,
    String currentUserId,
    String commentText,
    bool author,
    ctx,
    rating,
  ) async {
    commentsRef
        .doc(postModel.postuid)
        .collection('Comments')
        .doc(currentUserId)
        .set({
          'Timestamp': Timestamp.now(),
          "postuid": postModel.postuid,
          'commentText': commentText,
          'rating': rating,
          'byUserId': currentUserId,
          "author": author,
        })
        .whenComplete(() => Navigator.pop(ctx));
  }

  // setupIsMovieOnPlus18
  static Future<bool> setupIsMovieOnPlus18(String movieId) async {
    DocumentSnapshot movieDoc = await plus18Ref.doc(movieId).get();
    return movieDoc.exists;
  }

  // Get Comments
  static Future<List<CommentModel>> getComments(PostModel postModel) async {
    QuerySnapshot commentsSnap =
        await commentsRef
            .doc(postModel.postuid)
            .collection('Comments')
            .orderBy('rating', descending: true)
            .get();
    List<CommentModel> userComment =
        commentsSnap.docs.map((doc) => CommentModel.fromDoc(doc)).toList();

    return userComment;
  }

  // Delete Likes OF Posts
  static void deleteLikesOfPosts(postuid) async {
    await FirebaseFirestore.instance
        .collection('likes')
        .doc(postuid)
        .collection("Likes")
        .get()
        .then((snapshot) {
          for (DocumentSnapshot ds in snapshot.docs) {
            print("Deleting Likes.... {${ds.reference.id}}");
            ds.reference.delete();
          }
        });
  }

  // Delete Reefeds OF Feed
  static void deleteReefedsOfFeed(postuid) async {
    await FirebaseFirestore.instance
        .collection('reefeeds')
        .doc(postuid)
        .collection("Reefeeds")
        .get()
        .then((snapshot) {
          for (DocumentSnapshot ds in snapshot.docs) {
            print("Deleting Reefeds .... {${ds.reference.id}}");
            ds.reference.delete();
          }
        });
  }

  // delete post
  static void deletePost(PostModel postModel, context) async {
    final videoStorage = storageRef.child(
      "video's/${postModel.title}, ${postModel.postuid}.mp4",
    );
    final thumbnailStorage = storageRef.child(
      "thumbnail's/${postModel.title}, ${postModel.postuid}.jpg",
    );
    likesRef.doc(postModel.postuid).delete();
    reefeedsRef.doc(postModel.postuid).delete();
    // Delete Likes of Post
    deleteLikesOfPosts(postModel.postuid);
    try {
      postsRef
          .doc(postModel.userId)
          .collection('userPosts')
          .doc(postModel.id)
          .delete()
          .then((value) => moviesRef.doc(postModel.id).delete())
          .then((value) {
            moviesRef.doc(postModel.postuid).delete();
            moviesRef.doc(postModel.postuid).delete();
            likesRef.doc(postModel.postuid).delete();
            viewsRef.doc(postModel.postuid).delete();
          })
          .then((doc) async {
            QuerySnapshot followerSnapshot =
                await followersRef
                    .doc(postModel.userId)
                    .collection('Followers')
                    .get();
            for (var docSnapshot in followerSnapshot.docs) {
              await followingPostsRef
                  .doc(docSnapshot.id)
                  .collection('posts')
                  .doc(postModel.id)
                  .delete()
                  .whenComplete(() {
                    videoStorage.delete();
                    thumbnailStorage.delete();
                  });
            }
          });

      getUserPosts(postModel.userId);
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
        msg: "$e",
        backgroundColor: errorColor,
        textColor: Colors.white,
      );
    }
  }

  // Get User Posts
  static Future<List<PostModel>> getUserPosts(String userId) async {
    QuerySnapshot userPostsSnap =
        await postsRef
            .doc(userId)
            .collection('userPosts')
            .orderBy('Timestamp', descending: true)
            .get();
    List<PostModel> userPosts =
        userPostsSnap.docs.map((doc) => PostModel.fromDoc(doc)).toList();

    return userPosts;
  }

  // Get Feeds
  static Future<List<FeedModel>> getFeeds(String userId) async {
    List<FeedModel> feed = [];

    // Retrieve the list of users that the current user is following
    QuerySnapshot followingSnapshot =
        await followingRef.doc(userId).collection("Following").get();

    List<String> followingUsers =
        followingSnapshot.docs
            .map(
              (doc) => doc.id,
            ) // Assuming each document ID represents a user ID
            .toList();

    // Retrieve the posts from the feed collections of the following users
    for (String followingUserId in followingUsers) {
      QuerySnapshot userFeedSnapshot =
          await feedsRef.doc(followingUserId).collection("Feeds").get();
      List<FeedModel> userFeed =
          userFeedSnapshot.docs
              .map(
                (doc) => FeedModel.fromDoc(doc),
              ) // Assuming you have a Post model
              .toList();

      feed.addAll(userFeed);
    }

    // Sort the feed by timestamp or any other relevant criteria
    feed.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return feed;
  }

  // Get Links
  static Future<List<PostModel>> getLinks(String userId) async {
    QuerySnapshot userPostsSnap =
        await postsRef
            .doc(userId)
            .collection('userPosts')
            .orderBy('Timestamp', descending: true)
            .get();
    List<PostModel> userPosts =
        userPostsSnap.docs.map((doc) => PostModel.fromDoc(doc)).toList();

    return userPosts;
  }

  // Checking episode
  static Future<List<PostModel>> checkingEpisode(
    PostModel postModel,
    int series,
  ) async {
    QuerySnapshot userPostsSnap =
        await postsRef
            .doc(postModel.userId)
            .collection('userPosts')
            .doc(postModel.postuid)
            .collection('otherEpisodes')
            .where('episode', isNotEqualTo: series)
            .get();
    List<PostModel> userPosts =
        userPostsSnap.docs.map((doc) => PostModel.fromDoc(doc)).toList();

    return userPosts;
  }

  // Get Following User Posts
  static Future<List<PostModel>> getFollowingPosts(String userId) async {
    QuerySnapshot userPostsSnap =
        await followingPostsRef
            .doc(userId)
            .collection('posts')
            .orderBy('Timestamp', descending: true)
            .get();
    List<PostModel> userPosts =
        userPostsSnap.docs.map((doc) => PostModel.fromDoc(doc)).toList();
    userPosts.shuffle();
    return userPosts;
  }

  // Get Other Series
  static Future<List<PostModel>> getOtherEpisodes(PostModel postModel) async {
    QuerySnapshot userPostsSnap =
        await postsRef
            .doc(postModel.userId)
            .collection('userPosts')
            .doc(postModel.postuid)
            .collection('otherEpisode')
            .orderBy("episode", descending: false)
            .get();
    List<PostModel> userPosts =
        userPostsSnap.docs.map((doc) => PostModel.fromDoc(doc)).toList();

    return userPosts;
  }

  // Get Series
  static Future<List<SeriesModel>> getSeries(PostModel postModel) async {
    QuerySnapshot userPostsSnap =
        await postsRef
            .doc(postModel.userId)
            .collection('userPosts')
            .doc(postModel.postuid)
            .collection('Series')
            .orderBy("episode", descending: false)
            .get();
    List<SeriesModel> userPosts =
        userPostsSnap.docs.map((doc) => SeriesModel.fromDoc(doc)).toList();

    return userPosts;
  }

  static Future<List<PostModel>> getMovies() async {
    QuerySnapshot userPostsSnap =
        await moviesRef.orderBy("timestamp", descending: true).get();
    List<PostModel> userPosts =
        userPostsSnap.docs.map((doc) => PostModel.fromDoc(doc)).toList();

    return userPosts;
  }

  static Future<List<PostModel>> getPopularMovies() async {
    QuerySnapshot userPostsSnap =
        await moviesRef
            .orderBy('popularity', descending: true)
            .limit(10) // top 10 popular movies
            .get();
    List<PostModel> userPosts =
        userPostsSnap.docs.map((doc) => PostModel.fromDoc(doc)).toList();

    return userPosts;
  }

  // Get Explorer Post with Randomly
  static Future<List<PostModel>> getExplorerPostWithRandomly() async {
    QuerySnapshot exploerePostSnap = await moviesRef.get();
    List<PostModel> userPosts =
        exploerePostSnap.docs.map((doc) => PostModel.fromDoc(doc)).toList();

    // Shuffle the list items randomly
    userPosts.shuffle();

    return userPosts;
  }

  // Get Drama's
  static Future<List<PostModel>> getDramas() async {
    QuerySnapshot exploerePostSnap =
        await moviesRef.orderBy("Timestamp", descending: true).get();
    List<PostModel> userPosts =
        exploerePostSnap.docs.map((doc) => PostModel.fromDoc(doc)).toList();
    userPosts.shuffle();
    return userPosts;
  }

  // like post
  static void likePost(
    String postuid,
    String userId,
    String likedByUserid,
    String thumbnail,
    bool isFeed,
  ) async {
    try {
      await likesRef.doc(postuid).collection('Likes').doc(likedByUserid).set({
        'Timestamp': Timestamp.now(),
      });
      await postsRef
          .doc(userId)
          .collection('userPosts')
          .doc(postuid)
          .update({'likes': FieldValue.increment(1)})
          .then(
            (value) => moviesRef
                .doc(postuid)
                .update({'likes': FieldValue.increment(1)})
                .then(
                  (value) => moviesRef.doc(postuid).update({
                    'likes': FieldValue.increment(1),
                  }),
                ),
          );
    } catch (e) {
      print(e);
    }

    if (isFeed) {
      addActivity(
        userId,
        likedByUserid,
        postuid,
        false,
        true,
        thumbnail,
        isFeed,
      );
      await feedsRef.doc(userId).collection('Feeds').doc(postuid).update({
        'likes': FieldValue.increment(1),
      });
    } else {
      addActivity(
        userId,
        likedByUserid,
        postuid,
        false,
        true,
        thumbnail,
        isFeed,
      );
    }
  }

  // unloike post
  static void unlikePost(
    String postuid,
    String userId,
    String likedByUserid,
    String activityUuid,
    bool isFeed,
  ) async {
    await likesRef.doc(postuid).collection('Likes').doc(likedByUserid).delete();
    if (isFeed) {
    } else {
      await postsRef.doc(userId).collection('userPosts').doc(postuid).update({
        'likes': FieldValue.increment(-1),
      });
    }

    try {
      if (isFeed) {
        await feedsRef.doc(userId).collection('Feeds').doc(postuid).update({
          'likes': FieldValue.increment(-1),
        });
      } else {
        await moviesRef
            .doc(postuid)
            .update({'likes': FieldValue.increment(-1)})
            .then(
              (value) => moviesRef.doc(postuid).update({
                'likes': FieldValue.increment(-1),
              }),
            );
      }
    } catch (e) {
      print(e);
    }
    removeActivity(userId, likedByUserid, activityUuid, false, true);
  }

  // is Liked
  static Future<bool> isLikedPost(String postId, String currentUserId) async {
    DocumentSnapshot likedDoc =
        await likesRef.doc(postId).collection('Likes').doc(currentUserId).get();
    return likedDoc.exists;
  }

  // reefeed
  static void reefeed(
    String postuid,
    String userId,
    String refeedByUserid,
    String picture,
    bool isFeed,
  ) async {
    try {
      await reefeedsRef
          .doc(postuid)
          .collection('Reefeeds')
          .doc(refeedByUserid)
          .set({'Timestamp': Timestamp.now()});
      await feedsRef.doc(userId).collection('Feeds').doc(postuid).update({
        'refeed': FieldValue.increment(1),
      });
    } catch (e) {
      print(e);
    }
  }

  // unreefeed
  static void unreefeed(
    String postuid,
    String userId,
    String refeedByUserid,
    String picture,
    bool isFeed,
  ) async {
    try {
      await reefeedsRef
          .doc(postuid)
          .collection('Reefeeds')
          .doc(refeedByUserid)
          .delete();
      await feedsRef.doc(userId).collection('Feeds').doc(postuid).update({
        'refeed': FieldValue.increment(-1),
      });
    } catch (e) {
      print(e);
    }
  }

  static Future<int> getReedesCount(String postId) async {
    QuerySnapshot reedsSnapshot =
        await reefeedsRef.doc(postId).collection('Reefeeds').get();
    return reedsSnapshot.docs.length;
  }

  // isReefeded
  static Future<bool> isReefeded(String postId, String currentUserId) async {
    DocumentSnapshot reededDoc =
        await reefeedsRef
            .doc(postId)
            .collection('Reefeeds')
            .doc(currentUserId)
            .get();
    return reededDoc.exists;
  }

  // is User Created Chat Collection
  static Future<bool> isCollectionCreated(
    String currentUserId,
    String visistedUserId,
  ) async {
    DocumentSnapshot createdDoc =
        await addchatsRef
            .doc(currentUserId)
            .collection('Add')
            .doc(visistedUserId)
            .get();
    return createdDoc.exists;
  }

  // Get Collection Chats
  static Future<List<ChatModel>> getCollectionChats(String userid) async {
    QuerySnapshot usersSnap =
        await addchatsRef
            .doc(userid)
            .collection('Add')
            .orderBy('lastMessage Timestamp', descending: true)
            .get();

    List<ChatModel> users =
        usersSnap.docs.map((doc) => ChatModel.fromDoc(doc)).toList();
    return users;
  }

  // is Sent Request
  static Future<bool> isSentRequest(String currentUserId) async {
    DocumentSnapshot likedDoc = await requestsRef.doc(currentUserId).get();
    return likedDoc.exists;
  }

  // get likes
  static Future<int> getPostLikes(postId) async {
    QuerySnapshot likesSnapshot =
        await likesRef.doc(postId).collection('Likes').get();
    return likesSnapshot.docs.length;
  }

  // CreateCollection Message
  static void createCollection(String currentUserId, String visitedUserId) {
    addchatsRef
        .doc(currentUserId)
        .collection('Add')
        .doc(visitedUserId)
        .set({
          'visitedUserId': visitedUserId,
          'added User at ': Timestamp.now(),
          'lastMessage Timestamp': Timestamp.now(),
          'lastMessage text': '',
          'lastSeen': Timestamp.now(),
          'Typechat': 'Tap to chat',
          "isRead": false,
        })
        .then(
          (value) => addchatsRef
              .doc(visitedUserId)
              .collection('Add')
              .doc(currentUserId)
              .set({
                'visitedUserId': currentUserId,
                'added User at ': Timestamp.now(),
                'lastMessage Timestamp': Timestamp.now(),
                'lastMessage text': '',
                'lastSeen': Timestamp.now(),
                'Typechat': 'Tap to chat',
                "isRead": false,
              }),
        )
        .then((value) => print("Created Chat Collaction"));
  }

  static void removeCollection(String currentUserId, String visitedUserId) {
    addchatsRef
        .doc(currentUserId)
        .collection('Add')
        .doc(visitedUserId)
        .delete()
        .then(
          (value) =>
              addchatsRef
                  .doc(visitedUserId)
                  .collection('Add')
                  .doc(currentUserId)
                  .delete(),
        );
  }

  // SearchUsers
  static Future<QuerySnapshot> searchUsers(String username) async {
    Future<QuerySnapshot> users =
        usersRef
            .where('username', isGreaterThanOrEqualTo: username)
            .where('username', isLessThan: '${username}z')
            .get();

    return users;
  }

  // Search posts
  static Future<QuerySnapshot> searchPosts(String title) async {
    Future<QuerySnapshot> posts =
        moviesRef
            .where('title', isGreaterThanOrEqualTo: title)
            .where('title', isLessThan: '${title}z')
            .get();

    return posts;
  }

  // Search posts by tags
  static Future<QuerySnapshot> searchPostsbyTags(String tag) async {
    Future<QuerySnapshot> posts =
        moviesRef.where('tags', arrayContains: tag).get();

    return posts;
  }

  // Follow User
  static void followUser(
    String currentUserId,
    String visitedUserId,
    String activityID,
  ) {
    followingRef
        .doc(currentUserId)
        .collection('Following')
        .doc(visitedUserId)
        .set({
          'visitedUserId': visitedUserId,
          'followedUser at ': Timestamp.now(),
          'lastMessage Timestamp': Timestamp.now(),
          'lastMessage text': '',
        });
    followersRef
        .doc(visitedUserId)
        .collection('Followers')
        .doc(currentUserId)
        .set({
          'visitedUserId': visitedUserId,
          'followedUser at ': Timestamp.now(),
          'lastMessage Timestamp': Timestamp.now(),
        });

    addActivity(
      visitedUserId,
      currentUserId,
      activityID,
      true,
      false,
      '',
      false,
    );
  }

  static void addActivity(
    String visitedUserId,
    String currentUserId,
    String postId,
    follow,
    islikedPost,
    String thumbnail,
    bool isFeed,
  ) async {
    if (currentUserId != visitedUserId) {
      if (follow) {
        await activityRef
            .doc(visitedUserId)
            .collection('activity')
            .doc(currentUserId)
            .set({
              'Timestamp': Timestamp.now(),
              'ActivityType': 'following',
              'activityMessage': 'دوای تۆ کەوت',
              'byUserId': currentUserId,
              'thumbnail': '',
            });
      } else if (islikedPost) {
        await activityRef
            .doc(visitedUserId)
            .collection('activity')
            .doc(postId)
            .set({
              'Timestamp': Timestamp.now(),
              'ActivityType': 'liked post',
              'activityMessage':
                  isFeed ? "فییدەکەتی بەدڵبوو" : 'پۆستەکەتی بەدڵ بوو',
              'byUserId': currentUserId,
              'thumbnail': thumbnail,
            });
      }
    } else {
      print('object');
    }
  }

  static void removeActivity(
    String visitedUserId,
    String currentUserId,
    String postId,
    unfollow,
    likedPost,
  ) async {
    if (unfollow) {
      await activityRef
          .doc(visitedUserId)
          .collection('activity')
          .doc(currentUserId)
          .delete();
    } else if (likedPost) {
      await activityRef
          .doc(visitedUserId)
          .collection('activity')
          .doc(postId)
          .delete()
          .then((value) => print('Removed Activity'));
    }
  }

  // Get History
  static Future<List<HistoryModel>> getHistoryViews(String userId) async {
    QuerySnapshot userActivitySnap =
        await historyViews
            .doc(userId)
            .collection('Viewed')
            .orderBy('Timestamp', descending: true)
            .get();
    List<HistoryModel> userViewd =
        userActivitySnap.docs.map((doc) => HistoryModel.fromDoc(doc)).toList();

    return userViewd;
  }

  // Get Activity
  static Future<List<ActivityModel>> getActivities(String userId) async {
    QuerySnapshot userActivitySnap =
        await activityRef
            .doc(userId)
            .collection('activity')
            .orderBy('Timestamp', descending: true)
            .limit(25)
            .get();
    List<ActivityModel> userActivity =
        userActivitySnap.docs.map((doc) => ActivityModel.fromDoc(doc)).toList();
    print(userActivity.length);
    return userActivity;
  }

  // Unfollow User
  static void unFollowUser(
    String currentUserId,
    String visitedUserId,
    String activityID,
  ) async {
    await followingRef
        .doc(currentUserId)
        .collection('Following')
        .doc(visitedUserId)
        .get()
        .then((doc) {
          if (doc.exists) {
            doc.reference.delete();
          }
        });

    await followersRef
        .doc(visitedUserId)
        .collection('Followers')
        .doc(currentUserId)
        .get()
        .then((doc) {
          if (doc.exists) {
            doc.reference.delete();
          }
        });
    removeActivity(visitedUserId, currentUserId, activityID, true, false);
    removeCollection(currentUserId, visitedUserId);
  }

  // Is Following User
  static Future<bool> isFollowingUser(
    String currentUserId,
    String visitedUserId,
  ) async {
    DocumentSnapshot followingDoc =
        await followersRef
            .doc(visitedUserId)
            .collection('Followers')
            .doc(currentUserId)
            .get();
    return followingDoc.exists;
  }

  // is Blocking User
  static Future<bool> isBlockingUser(
    String currentUserId,
    String visitedUserId,
  ) async {
    DocumentSnapshot blockingDoc =
        await blockedRef
            .doc(currentUserId)
            .collection('Block')
            .doc(visitedUserId)
            .get();
    return blockingDoc.exists;
  }

  // isMeBlocked
  static Future<bool> isMeBlocked(
    String currentUserId,
    String visitedUserId,
  ) async {
    DocumentSnapshot blockingDoc =
        await blockedRef
            .doc(visitedUserId)
            .collection('Block')
            .doc(currentUserId)
            .get();
    return blockingDoc.exists;
  }

  // Is DarkMode User
  static Future<bool> isDarkMode(
    String currentUserId,
    String visitedUserId,
  ) async {
    DocumentSnapshot followingDoc =
        await addchatsRef
            .doc(currentUserId)
            .collection('Add')
            .doc(visitedUserId)
            .get();
    return followingDoc.exists;
  }

  // Followers Number
  static Future<int> followersNumber(String userId) async {
    QuerySnapshot followersSnapshot =
        await followersRef.doc(userId).collection('Followers').get();
    return followersSnapshot.docs.length;
  }

  // Following Number
  static Future<int> followingNumber(String userId) async {
    QuerySnapshot followingSnapshot =
        await followingRef.doc(userId).collection('Following').get();
    return followingSnapshot.docs.length;
  }

  // Block User
  static void blockUser(
    String currentUserId,
    String visitedUserId,
    String activityID,
  ) async {
    await blockedRef
        .doc(currentUserId)
        .collection('Block')
        .doc(visitedUserId)
        .set({
          'Timestamp': Timestamp.now(),
          'BlockedUser': visitedUserId,
          'BlockerUser': currentUserId,
        })
        .then(
          (value) => followingPostsRef
              .doc(currentUserId)
              .collection('post')
              .doc(visitedUserId)
              .delete()
              .whenComplete(() => print("You blocked: $visitedUserId")),
        );

    // Remove From Addchats
    removeCollection(currentUserId, visitedUserId);
    print('Removed from collection');
    unFollowUser(currentUserId, visitedUserId, activityID);
    print('Unfollowed User');
    followingRef
        .doc(visitedUserId)
        .collection('Following')
        .doc(currentUserId)
        .get()
        .then((doc) {
          if (doc.exists) {
            doc.reference.delete();
          }
          print('Removed you from following him');
        });
  }

  // Unblock User
  static void unblockUser(String currentUserId, String visitedUserId) async {
    await blockedRef
        .doc(currentUserId)
        .collection('Block')
        .doc(visitedUserId)
        .delete();
    print('Unblocked $visitedUserId');
  }

  // Update ActiviteTime
  static void updateUserActive(String currentUserId) async {
    await usersRef.doc(currentUserId).update({'ActiveTime': Timestamp.now()});
  }

  // Check Version
  static Future checkVersion(ctx) async {
    // Get the package info.
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // Print the version name and build number.
    print("Version: ${packageInfo.version}");
    print("BuildNumber: ${packageInfo.buildNumber}");
    // Check From Firestore
    var versionFromServer = '';
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance
            .collection('AppVersion')
            .doc('Android')
            .get();
    versionFromServer = documentSnapshot["version"];

    print("Version From Server: $versionFromServer");
    if (versionFromServer != packageInfo.version) {
      try {
        var url = documentSnapshot["UriRequest"];

        HAlertDialog.showCustomAlertBox(
          context: ctx,
          backgroundColor: moviePageColor,
          title: 'ناتوانی بەردەوام بیت',
          description: "وەشانی نوێ بەردەستە",
          icon: Icons.error_outline,
          iconSize: 32,
          iconColor: Colors.red,
          titleFontFamily: 'Sirwan',
          titleFontSize: 22,
          titleFontColor: Colors.red,
          descriptionFontFamily: 'Sirwan',
          descriptionFontColor: const Color.fromARGB(153, 0, 0, 0),
          descriptionFontSize: 18.5,
          timerInSeconds: 5,
        );
        Future.delayed(const Duration(seconds: 5), () async {
          try {
            if (await canLaunch(url)) {
              await launch(url);
              exit(0);
            } else {
              exit(0);
            }
          } catch (e) {
            Fluttertoast.showToast(msg: "$e");
          }
        });
      } catch (e) {
        print(e);
      }
    } else {
      print("latest version ${packageInfo.version}");
    }
    return versionFromServer;
  }

  // Get Following User
  static Stream<List<UserModell>> getFollowingUsersStream(String userId) {
    try {
      // Reference to the followers sub-collection for the specified user
      CollectionReference followingRef = FirebaseFirestore.instance
          .collection('following')
          .doc(userId)
          .collection('Following');

      // Stream of follower documents from the sub-collection
      Stream<QuerySnapshot> followingSnapshotStream = followingRef.snapshots();

      // Mapping the stream to a stream of follower users
      return followingSnapshotStream.asyncMap((snapshot) async {
        List<UserModell> followingUsers = [];

        for (DocumentSnapshot followingDoc in snapshot.docs) {
          DocumentSnapshot userSnapshot =
              await usersRef.doc(followingDoc.id).get();
          if (userSnapshot.exists) {
            UserModell followerUser = UserModell.fromDoc(userSnapshot);
            followingUsers.add(followerUser);
          }
        }
        return followingUsers;
      });
    } catch (e) {
      print('Error getting follower users: $e');
      return Stream.empty();
    }
  }

  // Get Follwers User
  static Stream<List<UserModell>> getFollowerUsersStream(String userId) {
    try {
      // Reference to the followers sub-collection for the specified user
      CollectionReference followersRef = FirebaseFirestore.instance
          .collection('followers')
          .doc(userId)
          .collection('Followers');

      // Stream of follower documents from the sub-collection
      Stream<QuerySnapshot> followersSnapshotStream = followersRef.snapshots();

      // Mapping the stream to a stream of follower users
      return followersSnapshotStream.asyncMap((snapshot) async {
        List<UserModell> followerUsers = [];

        for (DocumentSnapshot followerDoc in snapshot.docs) {
          DocumentSnapshot userSnapshot =
              await usersRef.doc(followerDoc.id).get();
          if (userSnapshot.exists) {
            UserModell followerUser = UserModell.fromDoc(userSnapshot);
            followerUsers.add(followerUser);
          }
        }
        return followerUsers;
      });
    } catch (e) {
      print('Error getting follower users: $e');
      return Stream.empty();
    }
  }
}
