import 'package:flutter/material.dart';
import 'package:get/get.dart';
class MyMessages{
  static success(String message){
    Get.snackbar('Success', message,colorText: Colors.white,backgroundColor: Colors.tealAccent.withOpacity(0.8));
  }
  static failed(String message){
    Get.snackbar('Error', message,colorText: Colors.white,backgroundColor: Colors.redAccent.withOpacity(0.9));
  }
  static prompt(String message)
  {
    Get.snackbar('Hey! ', message,colorText: Colors.white,backgroundColor: Colors.orangeAccent);
  }
  static progress()
  {
    Get.dialog(const Center(child: CircularProgressIndicator(
      strokeWidth: 2,
    ),));
  }
}