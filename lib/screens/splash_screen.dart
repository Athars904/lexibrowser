import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for SystemChrome
import 'package:lexibrowser/helpers/adhelper.dart';
import 'package:lexibrowser/screens/browser_screen.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Enable edge-to-edge system UI mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Delay opening the HomePage by 200 seconds
    Future.delayed(const Duration(seconds: 2), () {
  AdHelper.precacheInterstitialAd();
  AdHelper.precacheNativeAd();
  AdHelper.loadAppOpen();
      Get.off(() => const BrowserPage());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepOrange, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/br.png',
                      height: 250,
                      width: 250,
                    ),
                  ),
                  const SizedBox(
                    height: 1,
                  ),
                  Center(
                    child: Text(
                      'Lexi Browser',
                      style: GoogleFonts.rampartOne( // Apply Google Fonts
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
