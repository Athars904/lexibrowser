import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for SystemChrome
import 'package:madlyvpn/screens/browser_screen.dart';
import 'package:madlyvpn/screens/home_screen.dart';
import 'package:get/get.dart';

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

    // Delay opening the HomePage by 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Get.off(() => BrowserPage());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/dark.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center( // Center the content on the screen
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  const SizedBox(
                    height: 200,
                  ),
                  Center(
                    child: Image.asset(
                      'assets/images/madly.png',
                      width: constraints.maxHeight * 0.47,
                      // Adjust the width according to the screen height
                    ),
                  ),
                  const SizedBox(
                    height: 100,
                  ),

                  // Centered text
                  const Center(
                    child: Text(
                      'THE PROXY OF MADNESS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: Colors.white38,
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
