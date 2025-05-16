import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

// Auth
final _fireStore = FirebaseFirestore.instance;
final storageRef = FirebaseStorage.instance.ref();
// Colors
const Color profileBGcolor = Color(0xFFECECEC);
const Color redolor = Color(0xFFFD3730);
const Color appcolor = Color.fromARGB(255, 91, 80, 170);

const Color errorColor = Color.fromARGB(255, 216, 41, 10);
const Color textBlueColor = Color.fromARGB(255, 48, 116, 233);
const Color scaffoldDarkColor = Color.fromARGB(255, 44, 38, 58);
const Color appBarDarkColor = Color.fromARGB(255, 68, 61, 86);
const Color messageCardColors = Color.fromARGB(255, 249, 249, 249);
const Color moviePageColor = Color.fromARGB(255, 176, 0, 32);
const Color appBarColor = Color.fromARGB(255, 0, 0, 0);
// const Color moviePageColor = Color.fromARGB(255, 40, 31, 60);
const Color tileColor = Color.fromARGB(198, 41, 30, 65);
const Color shadowColor = Color.fromARGB(255, 125, 123, 123);
const Color unColor = Color.fromARGB(255, 53, 52, 55);
const Color whiteColor = Color.fromARGB(255, 255, 255, 255);
const Color verifiedColor = Color.fromARGB(255, 240, 95, 69);

// Refrences
final usersRef = _fireStore.collection('users');
final followersRef = _fireStore.collection('followers');
final followingRef = _fireStore.collection('following');
final chatsRef = _fireStore.collection('chats');
final addchatsRef = _fireStore.collection('addchats');
final activityRef = _fireStore.collection('activites');
final publicChatsRef = _fireStore.collection('publicChats');
final blockedRef = _fireStore.collection('blocked');
final likesRef = _fireStore.collection('likes');
final reefeedsRef = _fireStore.collection('reefeeds');
final requestsRef = _fireStore.collection('requests');
final postsRef = _fireStore.collection('posts');
final followingPostsRef = _fireStore.collection('followingPost');
final linksRef = _fireStore.collection('links');
final viewsRef = _fireStore.collection('views');
final moviesRef = _fireStore.collection('Movies');

final commentsRef = _fireStore.collection('comments');
final seriesRef = _fireStore.collection('series');
final movieReportsRef = _fireStore.collection('movieReports');
final feedsRef = _fireStore.collection('Feeds');
final historyViews = _fireStore.collection("historyView");
final plus18Ref = _fireStore.collection('+18');
final locationRef = _fireStore.collection('Location');
final newsRef = _fireStore.collection('News');

// Tags
final tags = [
  'ئاکشن',
  'کۆمیدیا',
  "ئەنیمێ",
  'ڕۆمانسی',
  'تراژیدی',
  'غەمگین',
  'ترسناک',
  'نهێنی',
  'گەڕان',
  'سەرکێشی',
  'تەکنەلۆجیا',
  'خەیاڵی زانستی',
  'خەیاڵی',
  'زیرەکی',
  'تاوانکاری',
  'ئه‌نیمه‌یشن',
  'دراما',
  'خێزانی',
  'کۆری',
  'چینی',
  'یابانی',
  'چیرۆكی هه‌ستبزوێن',
  'ژیاننامە',
  'دۆکیومێنتاری',
  'مێژووی',
  'جەنگ',
  'بەڵگەنامەی',
  '‌عەرەبی',
];

final String androidUitId = "5348869";
final String placementId = "Interstitial_Android";
final String androidbannerAds = "Banner_Android";
