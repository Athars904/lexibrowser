import 'dart:math';
import 'package:get/get.dart';
import 'package:madlyvpn/controllers/home_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:madlyvpn/helpers/messages.dart';
import 'package:madlyvpn/models/vpn.dart';
import 'package:madlyvpn/services/vpn_engine.dart';
import 'package:madlyvpn/helpers/pref.dart';
late Size mq;

class VpnCard extends StatelessWidget {
  final Vpn vpn;

  const VpnCard({super.key, required this.vpn});

  @override
  Widget build(BuildContext context) {
    final controller=Get.find<HomeController>();
    mq = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 5.0,
      margin: EdgeInsets.symmetric(vertical: mq.height*.01),
      child: InkWell(
        borderRadius: BorderRadius.circular(5.0),
        onTap: ()
        {
          controller.vpn.value=vpn;
          Pref.vpn=vpn;
          Get.back();
          if(controller.vpnState.value==VpnEngine.vpnDisconnected)
          {
            VpnEngine.stopVpn();
            controller.connectToVpn();
          }
          else
          {
            controller.connectToVpn();
          }
        },
        child: ListTile(
          textColor: Colors.white38,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Text(
            vpn.countryLong,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: Image.asset(
            'assets/flags/${vpn.countryShort.toLowerCase()}.png',
            width: 30, // Adjust width as needed
            height: 30, // Adjust height as needed
          ),
          subtitle: Row(
            children: [
              const Icon(Icons.speed_rounded, color: Colors.lightBlueAccent, size: 20.0),
              const SizedBox(width: 4),
              Text(
                _formatBytes(vpn.speed, 1),

              )
            ],
          ),

        ),
      ),
    );
  }
  String _formatBytes(int bytes,int decimals)
  {
    if(bytes<=0) {
      return "0 B";
    }
    const suffixes=["Mpbs"];
    var i=(log(bytes)/log(1024)).floor();
    return '${(bytes/pow(1024, i)).toStringAsFixed(decimals)} $suffixes';
  }
}
