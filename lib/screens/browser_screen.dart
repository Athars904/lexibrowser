import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lexibrowser/helpers/adhelper.dart';
import 'package:lexibrowser/screens/forums_screen.dart';
import 'package:lexibrowser/screens/home_screen.dart';
import 'package:lexibrowser/screens/subscriptionpage.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'package:lexibrowser/controllers/theme_controller.dart';
import 'package:lexibrowser/screens/user_profile.dart';
import 'dart:async';
import 'package:lexibrowser/controllers/nativeadcontroller.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lexibrowser/helpers/adhelper.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:lexibrowser/helpers/downloadable_extensions.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
final _adController=NativeAdController();
class BrowserPage extends StatefulWidget {
  const BrowserPage({super.key});

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class BrowserTab {
  final WebViewController controller;
  String url;
  bool isLoading;
  Set<String> bookmarks;

  BrowserTab({required this.controller, required this.url, this.isLoading = false, required this.bookmarks});
}

class _BrowserPageState extends State<BrowserPage> {
  double pageLoadProgress = 0.0;
  bool showSpinner=false;
  late TextEditingController textEditingController;
  late List<BrowserTab> tabs;
  int currentIndex = 0;
  late FocusNode focusNode;
  final ThemeController themeController = Get.put(ThemeController());
  var isDarkMode = false.obs;
  String downloadProgress = "";
  List<String> downloadedFiles = [];
  String searchEngineUrl = "https://www.google.com/";
  Set<String> bookmarks = {};
  int urlLoadCount = 0;
  String selectedSearchEngine = "google";
  List<Map<String, dynamic>> speedDials = [
    {"title": "Google", "url": "https://www.google.com", "icon": "assets/images/google.png", "isAsset": true},
    {"title": "Facebook", "url": "https://www.facebook.com", "icon": "assets/images/fb.png", "isAsset": true},
    {"title": "LinkedIn", "url": "https://www.linkedin.com", "icon": "assets/images/linkedin.png", "isAsset": true},
    {"title": "Instagram", "url": "https://www.instagram.com", "icon": "assets/images/insta.png", "isAsset": true},
    {"title": "Gmail", "url": "https://mail.google.com", "icon": "assets/images/mail.png", "isAsset": true},
    {"title": "ChatGPT", "url": "https://chat.openai.com", "icon": "assets/images/gpt.png", "isAsset": true},
    {"title": "YouTube", "url": "https://www.youtube.com", "icon": "assets/images/yt.png", "isAsset": true},
    {"title": "TikTok", "url": "https://www.tiktok.com", "icon": "assets/images/tiktok.png", "isAsset": true},
  ];
  final List<String> commonSchemes = [
    'mailto',
    'tel',
    'sms',
    'whatsapp',
    'market', // Play Store scheme
  ];

  final List<String> externalDomains = [
    'wa.me', // WhatsApp web link
    'play.google.com', // Play Store domain
  ];

  bool _shouldOpenExternally(String url) {
    Uri uri = Uri.parse(url);

    // Check if the URL scheme is in the common schemes list
    if (!['http', 'https'].contains(uri.scheme)) {
      return true;
    }

    // Check if the URL domain is in the external domains list
    if (externalDomains.contains(uri.host)) {
      return true;
    }

    return false;
  }
  String getSearchEngineUrl() {
    if (selectedSearchEngine == "bing") {
      return "https://www.bing.com/";
    }
    return "https://www.google.com/";
  }

  String getSearchQueryUrl(String query) {
    if (selectedSearchEngine == "bing") {
      return "https://www.bing.com/search?q=$query";
    }
    return "https://www.google.com/search?q=$query";
  }


  double opacityLevel = 1.0;

  List<String> history = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    textEditingController = TextEditingController();
    focusNode = FocusNode();

    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        focusNode.unfocus();
      }
      if (focusNode.hasFocus) {
        textEditingController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: textEditingController.text.length,
        );
      }
    });

    tabs = [createNewTab(searchEngineUrl)];

    // Load bookmarks when initializing the state
    loadBookmarks();
    loadHistory();
    loadSession();
  }


  @override
  void dispose() {
    saveSession();
    textEditingController.dispose();
    focusNode.dispose(); // Dispose of FocusNode
    super.dispose();
  }


  BrowserTab createNewTab(String url) {
    final controller = WebViewController();
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.setNavigationDelegate(NavigationDelegate(
      onPageStarted: (url) {
        setState(() {
          tabs[currentIndex].url = url;
          tabs[currentIndex].isLoading = true;
          pageLoadProgress = 0.0; // Reset progress when page starts loading
          saveSession(); // Save the session when the page starts loading

          // Increment the URL load count
          urlLoadCount++;
          if (urlLoadCount >= 7) {
            // Reset the counter
            urlLoadCount = 0;
            // Display the interstitial ad
            AdHelper.showInterstitialAd(onComplete: () {
              // Optionally, perform any action after the ad is closed
            });
          }
        });
      },
      onProgress: (progress) {
        setState(() {
          pageLoadProgress = progress / 100.0; // Update progress
        });
      },
      onPageFinished: (url) async {
        setState(() {
          tabs[currentIndex].url = url;
          textEditingController.text = url;
          tabs[currentIndex].isLoading = false;
          pageLoadProgress = 0.0;
          if (!history.contains(url)) {
            history.add(url);
            saveHistory(); // Save the updated history
          }
          saveSession(); // Save the session when the page finishes loading
        });
      },
      onNavigationRequest: (NavigationRequest request) {
        if (_shouldOpenExternally(request.url)) {
          _launchURL(request.url);
          return NavigationDecision.prevent;
        }
        if (_isDownloadable(request.url)) {
          downloadFile(request.url);
          return NavigationDecision.prevent;
        }
        setState(() {
          saveSession();
        });
        return NavigationDecision.navigate;
      },
    ));
    controller.loadRequest(Uri.parse(url));
    return BrowserTab(controller: controller, url: url, bookmarks: {});
  }
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }




  Future<void> saveBookmarks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('bookmarks', bookmarks.toList());
  }

  Future<void> loadBookmarks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bookmarks = prefs.getStringList('bookmarks')?.toSet() ?? {};
    });
  }
  Future<void> loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedHistory = prefs.getStringList('browsing_history');
    if (savedHistory != null) {
      setState(() {
        history = savedHistory;
      });
    }
  }
  Future<void> saveSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> urls = tabs.map((tab) => tab.url).toList();
    prefs.setStringList('open_tabs', urls);
    prefs.setInt('current_index', currentIndex);
  }
  Future<void> loadSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedUrls = prefs.getStringList('open_tabs');
    int? savedIndex = prefs.getInt('current_index');

    if (savedUrls != null && savedUrls.isNotEmpty) {
      setState(() {
        tabs = savedUrls.map((url) => createNewTab(url)).toList();
        currentIndex = savedIndex ?? 0;
      });
    } else {
      tabs = [createNewTab(searchEngineUrl)];
    }
  }



  bool _isDownloadable(String url) {
    for (String extension in supportedFileExtensions) {
      if (url.endsWith(extension)) {
        return true;
      }
    }
    return false;

  }
  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      }
    } catch (err, stack) {
      print("Cannot get download folder path: $err");
    }
    return directory?.path;
  }



  Future<bool> storagePermission() async {
    final DeviceInfoPlugin info = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await info.androidInfo;
    final int androidVersion = int.parse(androidInfo.version.release);
    bool havePermission = false;

    if (androidVersion >= 11) {
      final status = await Permission.manageExternalStorage.request();
      havePermission = status.isGranted;
    } else {
      final status = await Permission.storage.request();
      havePermission = status.isGranted;
    }

    if (!havePermission) {
      await openAppSettings();
    }

    return havePermission;
  }



  Future<void> downloadFile(String url) async {
    bool permissionGranted = await storagePermission();

    if (!permissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied. Please enable it in settings.')),
      );
      return;
    }

    var dio = Dio();
    var dir = await getDownloadPath(); // Use getDownloadPath method

    // Sanitize the file name by removing unsafe characters
    String fileName = url.split('/').last.replaceAll(RegExp(r'[^\w\s.-]'), '');
    String filePath = "$dir/$fileName";

    try {
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              downloadProgress = (received / total * 100).toStringAsFixed(0) + "%";
            });
          }
        },
      );
      setState(() {
        downloadedFiles.add(filePath);
        downloadProgress = ""; // Reset the progress
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download completed: $fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }



    @override
  Widget build(BuildContext context) {
    final ThemeController themeController=Get.find();
    return SafeArea(
      child: WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60.0),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
              ),
              child: ModalProgressHUD(
                inAsyncCall: showSpinner,
                child: AppBar(
                  leading: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => HomeScreen(),
                      );
                    },
                    child: Image.asset(
                      'assets/images/vpn2.png', // Replace with your asset path
                      width: 10, // Adjust size as needed
                      height: 10,
                    ),
                  ),
                  title: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Image.asset(
                                'assets/images/google.png',
                                width: 24,
                                height: 24,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                focusNode: focusNode, // Use the FocusNode
                                style: const TextStyle(color: Colors.black),
                                controller: textEditingController,
                                decoration: InputDecoration(
                                  helperStyle: const TextStyle(
                                    color: Colors.black,
                                  ),
                                  hintText: "Search or type web address",
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.search, color: Colors.black),
                                    onPressed: () {
                                      loadUrl(textEditingController.text);
                                    },
                                  ),
                                ),
                                onSubmitted: (value) {
                                  loadUrl(value);
                                  focusNode.unfocus();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (pageLoadProgress > 0 && pageLoadProgress < 1.0) // Add progress bar
                        LinearProgressIndicator(
                          value: pageLoadProgress,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.bookmark_outline, color: bookmarks.contains(tabs[currentIndex].url) ? Colors.yellow : Colors.grey),
                      onPressed: () async {
                        setState(() {
                          if (bookmarks.contains(tabs[currentIndex].url)) {
                            bookmarks.remove(tabs[currentIndex].url);
                          } else {
                            bookmarks.add(tabs[currentIndex].url);
                          }
                        });
                        // Save bookmarks to shared preferences
                        await saveBookmarks();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return SingleChildScrollView(
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    topRight: Radius.circular(20.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10.0,
                                      spreadRadius: 5.0,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        InkWell(
                                          onTap: showBookmarksDialog,
                                          child: const Column(
                                            children: [
                                              Icon(Icons.bookmark, size: 40, color: Colors.blue),
                                              SizedBox(height: 8),
                                              Text('Bookmark', style: TextStyle(fontSize: 14)),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: showHistoryDialog,
                                          child: const Column(
                                            children: [
                                              Icon(Icons.history, size: 40, color: Colors.green),
                                              SizedBox(height: 8),
                                              Text('History', style: TextStyle(fontSize: 14)),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            AdHelper.showInterstitialAd(onComplete: ()
                                            {
                                              themeController.isDarkMode.value = !themeController.isDarkMode.value;
                                            });
                              
                                          },
                                          child: buildThemeToggle(),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            toggleSearchEngine();
                                            Navigator.pop(context); // Close the bottom sheet
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Search engine switched to ${selectedSearchEngine.capitalizeFirst}.')),
                                            );
                                          },
                                          child: Column(
                                            children: [
                                              Icon(
                                                selectedSearchEngine == "google" ? Icons.search : Icons.search_off,
                                                size: 40,
                                                color: selectedSearchEngine == "google" ? Colors.blue : Colors.green,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Switch to ${selectedSearchEngine == "google" ? "Bing" : "Google"}',
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),

                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    const Divider(thickness: 2.0),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            setState(() {
                                              if (bookmarks.contains(tabs[currentIndex].url)) {
                                                bookmarks.remove(tabs[currentIndex].url);
                                              } else {
                                                bookmarks.add(tabs[currentIndex].url);
                                              }
                                            });
                                            // Save bookmarks to shared preferences
                                            await saveBookmarks();
                                          },
                                          child: const Column(
                                            children: [
                                              Icon(Icons.save, size: 40, color: Colors.red),
                                              SizedBox(height: 8),
                                              Text('Save Page', style: TextStyle(fontSize: 14)),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: ()
                                          => Get.to(()=>const SubscriptionPage()),
                                          child: const Column(
                                            children: [
                                              Icon(Icons.ad_units, size: 40, color: Colors.purple),
                                              SizedBox(height: 8),
                                              Text('Block Ads', style: TextStyle(fontSize: 14)),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Get.to(() => Profile());
                                          },
                                          child: const Column(
                                            children: [
                                              Icon(Icons.person, size: 40, color: Colors.indigo),
                                              SizedBox(height: 8),
                                              Text('User Profile', style: TextStyle(fontSize: 14)),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: showDownloadsDialog,
                                          child: const Column(
                                            children: [
                                              Icon(Icons.download_outlined, size: 40, color: Colors.green),
                                              SizedBox(height: 8),
                                              Text('Downloads', style: TextStyle(fontSize: 14)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 40),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: OrientationBuilder(
            builder: (context, orientation) {
              return Container(
                decoration: const BoxDecoration(),
                child: Column(
                  children: [
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: _buildCurrentPage(),
                      ),
                    ),
                    _buildBottomWidget(),
                  ],
                ),
              );
            },
          ),


        ),
      ),
    );
  }

  Future<bool> onWillPop() async {
    if (await tabs[currentIndex].controller.canGoBack()) {
      tabs[currentIndex].controller.goBack();
      return Future.value(false);
    } else {
      final shouldClose = await showDialog<bool>(
        builder: (context) => AlertDialog(
          elevation: 2.0,
          title: const Text('Confirm Exit'),
          content: const Text('Are you sure you want to close the app?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        ),
        context: context,
      );
      return shouldClose ?? false;
    }
  }



  void loadUrl(String value) {
    Uri uri;
    // Check if the value is a valid URL
    if (value.startsWith("http://") || value.startsWith("https://")) {
      uri = Uri.parse(value);
    } else if (value.contains(".")) {
      // If it contains a dot, assume it's a full domain
      uri = Uri.parse("http://$value");
    } else {
      // Otherwise, treat it as a search term and use the selected search engine
      uri = Uri.parse(getSearchQueryUrl(value));
    }

    setState(() {
      tabs[currentIndex].url = uri.toString();
      textEditingController.text = uri.toString(); // Update the search bar with the current URL
      focusNode.unfocus(); // Remove focus from the TextField
    });
    tabs[currentIndex].controller.loadRequest(uri);
  }

  void toggleSearchEngine() {
    setState(() {
      if (selectedSearchEngine == "google") {
        selectedSearchEngine = "bing";
      } else {
        selectedSearchEngine = "google";
      }
    });
  }




  Widget buildThemeToggle() {
    return Column(
      children: [
        Obx(() {
          return Icon(
            themeController.isDarkMode.value ? Icons.dark_mode : Icons.light_mode,
            size: 40,
            color: themeController.isDarkMode.value ? Colors.yellow : Colors.black,
          );
        }),
        const SizedBox(height: 8),
        Obx(() {
          return Text(
            themeController.isDarkMode.value ? 'Dark Mode' : 'Light Mode',
            style: const TextStyle(fontSize: 14),
          );
        }),
      ],
    );
  }

  Widget _buildCurrentPage() {
    if (tabs[currentIndex].url == searchEngineUrl && tabs.length == 1) {
      return _buildHomePage();
    } else {
      return Stack(
        children: [
          WebViewWidget(controller: tabs[currentIndex].controller),
          if (downloadProgress.isNotEmpty) ...[
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: double.parse(downloadProgress.replaceAll('%', '')) / 100,
                    backgroundColor: Colors.grey,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Download Progress: $downloadProgress',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    }
  }


  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 3 / 4,
              ),
              itemCount: speedDials.length,
              itemBuilder: (context, index) {
                return _buildSpeedDialItem(index);
              },
            ),
            const SizedBox(height: 20),
            _buildShortcutsSection(),
          ],
        ),
      ),
    );
  }


  Widget _buildSpeedDialItem(int index) {
    return GestureDetector(
      onTap: () {
        String url = speedDials[index]['url']!;
        setState(() {
          tabs.add(createNewTab(url));
          currentIndex = tabs.length - 1;
        });
      },
      onLongPress: () {
        showDeleteSpeedDialDialog(index);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: speedDials[index]['isAsset']
                  ? Image.asset(
                speedDials[index]['icon']!,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              )
                  : Image.network(
                speedDials[index]['icon']!,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 50,
                    width: 50,
                    color: Colors.grey[300],
                    child: const Icon(Icons.language, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              child: Text(
                speedDials[index]['title']!,
                style: const TextStyle( fontWeight: FontWeight.bold, fontSize: 12),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }





  Widget _buildShortcutsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        const SizedBox(height: 30),
        const Text(
          'Services',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildShortcutButton('VPN', Icons.security, showVPNPage),
            _buildShortcutButton('Forums', Icons.forum, showForumsPage),
          ],
        ),

      ],
    );
  }


  Widget _buildShortcutButton(String title, IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.lightBlueAccent, Colors.grey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.transparent,
              child: Icon(icon, size: 30, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }


  Widget _buildBottomWidget() {
    return Container(
      decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(
                  color: Colors.grey,
                  width: 1.0
              )
          )
      ),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, ),
              onPressed: () async {
                if (await tabs[currentIndex].controller.canGoBack()) {
                  tabs[currentIndex].controller.goBack();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward, ),
              onPressed: () async {
                if (await tabs[currentIndex].controller.canGoForward()) {
                  tabs[currentIndex].controller.goForward();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.tab, ),
              onPressed: showTabSwitcherDialog,
            ),
            IconButton(
              icon: const Icon(Icons.home, ),
              onPressed: () {
                setState(() {
                  tabs[currentIndex] = createNewTab(searchEngineUrl);
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh, ),
              onPressed: () {
                tabs[currentIndex].controller.reload();
              },
            ),
          ],
        ),
      ),
    );
  }

  void showDownloadsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Downloaded Files'),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (downloadProgress.isNotEmpty) ...[
                      LinearProgressIndicator(
                        value: double.parse(downloadProgress.replaceAll('%', '')) / 100,
                        backgroundColor: Colors.grey,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Download Progress: $downloadProgress',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: downloadedFiles.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(downloadedFiles[index].split('/').last),
                            onTap: () async {
                              OpenResult result = await OpenFile.open(downloadedFiles[index]);
                              if (result.type != ResultType.done) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Cannot open this file')),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> saveHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('browsing_history', history);
  }


  void showTabSwitcherDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            height: 400,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Tabs',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.blueAccent),
                      onPressed: () {
                        setState(() {
                          tabs.add(createNewTab(searchEngineUrl));
                          currentIndex = tabs.length - 1;
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 3 / 4,
                    ),
                    itemCount: tabs.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                currentIndex = index;
                              });
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: index == currentIndex ? Colors.blueAccent.withOpacity(0.1) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      getFaviconUrl(tabs[index].url),
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 50,
                                          width: 50,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.language, color: Colors.grey),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    getDomainName(tabs[index].url),
                                    style: TextStyle(
                                      color: index == currentIndex ? Colors.blueAccent : Colors.white,
                                      fontWeight: index == currentIndex ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: -2,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (tabs.length > 1) {
                                    tabs.removeAt(index);
                                    if (currentIndex >= index && currentIndex > 0) {
                                      currentIndex--;
                                    }
                                  }
                                  saveSession();
                                });
                                Navigator.of(context).pop();
                                showTabSwitcherDialog(); // Reopen dialog to reflect changes
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.close, color: Colors.red, size: 16),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  String getFaviconUrl(String url) {
    Uri uri = Uri.parse(url);
    return "${uri.scheme}://${uri.host}/favicon.ico";
  }

  String getDomainName(String url) {
    Uri uri = Uri.parse(url);
    return uri.host;
  }



  Widget _buildTabItem(int index) {
    return ListTile(
      title: Text(tabs[index].url),
      trailing: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          setState(() {
            if (tabs.length > 1) {
              tabs.removeAt(index);
              if (currentIndex >= index && currentIndex > 0) {
                currentIndex--;
              }
            }
          });
          Navigator.pop(context);
        },
      ),
      onTap: () {
        setState(() {
          currentIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }

  void showBookmarksDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bookmarks'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = bookmarks.elementAt(index);
              return ListTile(
                leading: Image.network(
                  getFaviconUrl(bookmark),
                  width: 24,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.language);
                  },
                ),
                title: Text(
                  bookmark,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueAccent,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () async {
                    setState(() {
                      bookmarks.remove(bookmark);
                    });
                    await saveBookmarks();
                    Navigator.pop(context);
                    showBookmarksDialog();
                  },
                ),
                onTap: () {
                  Navigator.pop(context);
                  loadUrl(bookmark);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }



  void showHistoryDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: history.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Image.network(
                  getFaviconUrl(history[index]),
                  width: 24,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.language, color: Colors.grey);
                  },
                ),
                title: Text(
                  history[index],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueAccent,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                onTap: () {
                  Navigator.pop(context);
                  loadUrl(history[index]);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                history.clear();
              });
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove('browsing_history'); // Clear saved history
              Navigator.pop(context);
            },
            child: const Text('Clear History'),
          ),
        ],
      ),
    );
  }





  Future<String?> showAddSpeedDialDialog() async {
    TextEditingController urlController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Speed Dial'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(hintText: 'Enter URL'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, urlController.text);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void showDeleteSpeedDialDialog(int index) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Speed Dial'),
        content: const Text('Are you sure you want to delete this speed dial?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                speedDials.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void showVPNPage() {
    setState(() {
      showModalBottomSheet(
        context: context,
        builder: (context) => HomeScreen(),
      );
    });
  }

  void showForumsPage() {
    setState(() {
      Get.to(()=>ChatScreen());
    });
  }
}
