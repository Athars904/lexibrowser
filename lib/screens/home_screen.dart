// home_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lexibrowser/controllers/home_controller.dart';
import 'package:lexibrowser/screens/location_screen.dart';
import 'package:lexibrowser/widgets/home_card.dart';
import '../models/vpn_status.dart';
import '../services/vpn_engine.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:lexibrowser/screens/browser_screen.dart'; // Ensure this import

late Size mq;

class HomeScreen extends StatelessWidget {
  final _controller = Get.put(HomeController());
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    VpnEngine.vpnStageSnapshot().listen((event) {
      _controller.vpnState.value = event;
    });
    mq = MediaQuery.of(context).size;
    return SafeArea(
      child: Container(
        color: Colors.transparent,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Lexi VPN',
              style: GoogleFonts.merriweather(
                textStyle: const TextStyle(

                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
          bottomNavigationBar: Semantics(
            button: true,
            child: InkWell(
              onTap: () {
                
                showModalBottomSheet(
                  context: context,
                  builder: (context) => LocationScreen(),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF546E7A), // Darker grey shade
                      Color(0xFF78909C), // Light grey shade
                      Color(0xFF0D47A1), // Dark blue shade
                      Color(0xFF1976D2), // Light blue shade
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: mq.width * .04),
                child: const Row(
                  children: [
                    Icon(
                      CupertinoIcons.globe,
                      size: 28,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Select Server',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    Spacer(),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.navigate_next_rounded, color: Colors.indigo),
                    )
                  ],
                ),
              ),
            ),
          ),
          body: Obx(() => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: mq.height * .10,
                  width: double.maxFinite,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _controller.vpn.value.countryShort.isNotEmpty
                            ? Image.asset(
                          'assets/flags/${_controller.vpn.value.countryShort.toLowerCase()}.png',
                          width: 25.0,
                          height: 25.0,
                          fit: BoxFit.cover,
                        )
                            : const Icon(
                          Icons.public, // World icon
                          size: 25.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _controller.vpn.value.countryLong.isEmpty
                          ? 'Country'
                          : _controller.vpn.value.countryLong,
                      style: TextStyle(
            
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                _vpnButton(),
              ],
            ),
          )),
        ),
      ),
    );
  }

  Widget _vpnButton() => Column(
    children: [
      Semantics(
        button: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () {
            _controller.connectToVpn();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _controller.getButtonColor.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  _controller.getButtonColor.withOpacity(0.7),
                  _controller.getButtonColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              width: mq.height * 0.14,
              height: mq.height * 0.14,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Center(
                child: Stack(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: Icon(
                        CupertinoIcons.power,
                        key: ValueKey<bool>(_controller.vpnState.value == VpnEngine.vpnConnected),
                        size: _controller.vpnState.value == VpnEngine.vpnConnected ? 60 : 40,
                        color: _controller.getButtonColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      Container(
        margin: EdgeInsets.only(top: mq.height * 0.015),
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [
              _controller.getButtonColor.withOpacity(0.7),
              _controller.getButtonColor.withOpacity(0.9),
              _controller.getButtonColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _controller.getButtonColor.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _controller.vpnState.value == VpnEngine.vpnDisconnected
                  ? Icons.close
                  : Icons.check,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              _controller.vpnState.value == VpnEngine.vpnDisconnected
                  ? 'Not Connected'
                  : _controller.vpnState.replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    ],
  );
}