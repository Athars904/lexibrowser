import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:lexibrowser/controllers/location_controller.dart';
import 'package:get/get.dart';
import 'package:lexibrowser/widgets/vpncard.dart';
import 'package:lexibrowser/controllers/nativeadcontroller.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lexibrowser/helpers/adhelper.dart';

late Size mq;

class LocationScreen extends StatelessWidget {
  LocationScreen({Key? key}) : super(key: key);

  final _controller = Get.put(LocationController());
  final _adController = Get.put(NativeAdController());

  @override
  Widget build(BuildContext context) {
    if (_controller.vpnList.isEmpty) _controller.getVPNData();
    mq = MediaQuery.of(context).size;

    return FutureBuilder(
      future: loadAd(),
      builder: (context, snapshot) {
        return Obx(
              () => Scaffold(
            bottomNavigationBar: _adController.ad != null &&
                _adController.adLoaded.isTrue
                ? SafeArea(
              child: SizedBox(
                height: 80,
                child: AdWidget(ad: _adController.ad!),
              ),
            )
                : null,
            backgroundColor: Colors.transparent,
            floatingActionButton: FloatingActionButton(
              onPressed: () => _controller.getVPNData(),
              child: const Icon(Icons.refresh),
            ),
            body: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent.withOpacity(0.3), // Light blue accent
                    Colors.grey.withOpacity(0.3) // Light grey
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: _controller.isLoading.value
                  ? _loadingWidget()
                  : _controller.vpnList.isEmpty
                  ? _noVPNFound()
                  : _vpnData(),
            ),
          ),
        );
      },
    );
  }

  Future<void> loadAd() async {
    _adController.ad = await AdHelper.loadNativeAd(_adController);
  }

  Widget _vpnData() => ListView.builder(
    itemCount: _controller.vpnList.length,
    padding: EdgeInsets.only(
      top: mq.height * .02,
      bottom: mq.height * .1,
      left: mq.width * .04,
      right: mq.width * .04,
    ),
    physics: const BouncingScrollPhysics(),
    itemBuilder: (context, index) =>
        VpnCard(vpn: _controller.vpnList[index]),
  );

  Widget _loadingWidget() => SizedBox(
    width: double.infinity,
    height: double.infinity,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LottieBuilder.asset(
            'assets/lottie/lottieanim.json',
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 20),
          const Text(
            'Getting the best servers for you',
            style: TextStyle(fontSize: 18, color: Colors.black54),
          )
        ],
      ),
    ),
  );

  Widget _noVPNFound() => const Center(
    child: Text(
      'No VPN Servers Found',
      style: TextStyle(
          color: Colors.black54,
          fontSize: 22,
          fontWeight: FontWeight.bold),
    ),
  );
}
