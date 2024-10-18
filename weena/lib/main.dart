import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:weena/Constant/constant.dart';
import 'package:weena/LocalString.dart';
import 'package:weena/Screens/Welcome/welcome.dart';
import 'package:weena/Services/DatabaseServices.dart';
import 'Screens/bottomNavigation/bottomNAV.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await UnityAds.init(
    gameId: androidUitId,
    onComplete: () => print('Initialization Complete'),
    onFailed: (error, message) =>
        print('Initialization Failed: $error $message'),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var id;
  static Widget getScreenId() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user != null) {
            return Feed(
              currentUserId: user.uid,
            );
          } else {
            return const WelcomeScreen(isSkiped: false);
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  @override
  void initState() {
    DatabaseServices.checkVersion(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        translations: LocalString(),
        locale: const Locale('krd', 'IQ'),
        theme: ThemeData.light(),
        debugShowCheckedModeBanner: false,
        title: 'Weena',
        home: getScreenId(),
        routes: <String, WidgetBuilder>{
          "/welcomescreen": (BuildContext context) => const WelcomeScreen(
                isSkiped: false,
                currentUserId: "",
              ),
          "/feed": (BuildContext context) => const Feed(),
        });
  }
}
