// // browser_controller.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:madlyvpn/models/tab_model.dart';
//
// class BrowserController extends GetxController {
//   final List<TabModel> _tabs = [TabModel(title: 'New Tab', url: 'https://www.example.com')];
//
//   List<TabModel> get tabs => _tabs;
//
//   void addTab(String url) {
//     _tabs.add(TabModel(title: 'New Tab', url: url));
//     update();
//   }
//
//   void removeTab(int index) {
//     _tabs.removeAt(index);
//     update();
//   }
//
//   void setSelectedTabIndex(int index) {
//     // You can implement the logic to switch to the selected tab here
//   }
// }