import 'package:get/get.dart';
import 'package:madlyvpn/helpers/pref.dart';
import 'package:madlyvpn/models/vpn.dart';
import 'package:madlyvpn/APIS/apis.dart';
class LocationController extends GetxController{
  List<Vpn> vpnList = Pref.vpnList;

  final RxBool isLoading = false.obs;
  Future<void>getVPNData()async{
    isLoading.value=true;
    vpnList.clear();
    vpnList=await APIs.getVPNServers();
    isLoading.value=false;
  }

}