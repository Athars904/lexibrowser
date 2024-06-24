import 'package:webview_flutter/webview_flutter.dart';
class BrowserTab {
  final WebViewController controller;
  String url;
  bool isLoading;

  BrowserTab({required this.controller, required this.url, this.isLoading = false});
}
