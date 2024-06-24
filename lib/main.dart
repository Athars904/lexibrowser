import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:madlyvpn/screens/splash_screen.dart';
import 'package:get/get.dart';
import 'package:madlyvpn/helpers/pref.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  await Pref.initializeHive();
  // await FlutterDownloader.initialize(debug: true);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((value){
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lexi Browser',
      home: SplashScreen(),
    );
  }
}
