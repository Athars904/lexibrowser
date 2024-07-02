import 'package:get/get.dart';
import 'package:lexibrowser/helpers/adhelper.dart';
import 'package:lexibrowser/helpers/messages.dart';
import 'package:lexibrowser/services/vpn_engine.dart';
import 'package:flutter/material.dart';
import 'package:lexibrowser/models/vpn.dart';
import 'dart:convert';
import 'package:lexibrowser/models/vpn_config.dart';
import 'package:lexibrowser/helpers/pref.dart';
class HomeController extends GetxController{
  RxString vpnState = VpnEngine.vpnDisconnected.obs;
  final Rx<Vpn> vpn = Pref.vpn.obs;


  Future<void> connectToVpn() async {
    ///Stop right here if user not select a vpn
    if(vpn.value.openVPNConfigDataBase64.isEmpty) {
      MyMessages.prompt('Select a server first');
      return;
    }


    if (vpnState.value == VpnEngine.vpnDisconnected) {
      final data = const Base64Decoder().convert(vpn.value.openVPNConfigDataBase64);
      final config = const Utf8Decoder().convert(data);
      final vpnConfig = VpnConfig(
          country: vpn.value.countryLong,
          username: 'vpn',
          password: 'vpn',
          config: config);
      AdHelper.showInterstitialAd(onComplete: ()async{
        await VpnEngine.startVpn(vpnConfig);
      });

    }
    VpnEngine.stopVpn();
  }
  Color get getButtonColor {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return Colors.grey;
      case VpnEngine.vpnConnected:
        return Colors.blue.shade700;
      default:
        return Colors.orangeAccent;
    }
  }


  String get getButtonText{
    switch(vpnState.value)
    {
      case VpnEngine.vpnDisconnected:
        return 'Tap to Connect';
      case VpnEngine.vpnConnected:
        return 'Connected';
      default:
        return 'Connecting';
    }
  }

}