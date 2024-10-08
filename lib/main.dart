import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lexibrowser/screens/splash_screen.dart';
import 'package:get/get.dart';
import 'package:lexibrowser/helpers/pref.dart';
import 'package:lexibrowser/controllers/theme_controller.dart'; // Add this import
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controllers/profile_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:lexibrowser/helpers/adhelper.dart';
import 'package:lexibrowser/helpers/remoteconfig.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Config.initConfig();
  await AdHelper.initAds();
  await FlutterDownloader.initialize(debug: true);

  await Permission.storage.request();
  await Pref.initializeHive();
  // await FlutterDownloader.initialize(debug: true);
  Get.put(ProfileController());
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  final ThemeController themeController = Get.put(ThemeController());

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Lexi Browser',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: themeController.theme, // Use themeController to manage theme mode
        home: SplashScreen(),
      );
    });
  }
}
