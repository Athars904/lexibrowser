import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:madlyvpn/screens/splash_screen.dart';
import 'package:get/get.dart';
import 'package:madlyvpn/helpers/pref.dart';
import 'package:madlyvpn/screens/browser_screen.dart';
import 'package:madlyvpn/controllers/theme_controller.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  await Pref.initializeHive();
  // await FlutterDownloader.initialize(debug: true);
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
