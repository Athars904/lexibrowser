import 'package:flutter/material.dart';
import 'package:madlyvpn/screens/home_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
  late TextEditingController textEditingController;
  late List<BrowserTab> tabs;
  int currentIndex = 0;
  String searchEngineUrl = "https://www.google.com/";
  Set<String> bookmarks = {};
  List<Map<String, String>> speedDials = [
    {"title": "Google", "url": "https://www.google.com", "icon": "https://www.google.com/favicon.ico"},
    {"title": "LinkedIn", "url": "https://www.linkedin.com", "icon": "https://www.linkedin.com/favicon.ico"},
    {"title": "Insta", "url": "https://www.instagram.com", "icon": "https://www.instagram.com/favicon.ico"},
    {"title": "Gmail", "url": "https://mail.google.com", "icon": "https://mail.google.com/favicon.ico"},
    {"title": "Yahoo", "url": "https://www.yahoo.com", "icon": "https://www.yahoo.com/favicon.ico"},
    {"title": "YouTube", "url": "https://www.youtube.com", "icon": "https://www.youtube.com/favicon.ico"},
    {"title": "TikTok", "url": "https://www.tiktok.com", "icon": "https://www.tiktok.com/favicon.ico"},
  ];

  double opacityLevel = 1.0;

  List<String> history = [];

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    tabs = [createNewTab(searchEngineUrl)];
  }

  @override
  void dispose() {
    textEditingController.dispose();
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
        });
      },
      onPageFinished: (url) {
        setState(() {
          tabs[currentIndex].url = url;
          textEditingController.text = url; // Update the search bar with the current URL
          tabs[currentIndex].isLoading = false;
          if (!history.contains(url)) {
            history.add(url);
          }
        });
      },
    ));
    controller.loadRequest(Uri.parse(url));
    return BrowserTab(controller: controller, url: url, bookmarks: {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60.0),
            child: AppBar(
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.grey],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              title: Container(
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
                child: TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                    hintText: "Search or type web address",
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        loadUrl(textEditingController.text);
                      },
                    ),
                  ),
                  onSubmitted: (value) {
                    loadUrl(value);
                  },
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.bookmark, color: bookmarks.contains(tabs[currentIndex].url) ? Colors.yellow : Colors.white),
                  onPressed: () {
                    setState(() {
                      if (bookmarks.contains(tabs[currentIndex].url)) {
                        bookmarks.remove(tabs[currentIndex].url);
                      } else {
                        bookmarks.add(tabs[currentIndex].url);
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.tab),
                  onPressed: () {
                    showTabSwitcherDialog();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      tabs.add(createNewTab(searchEngineUrl));
                      currentIndex = tabs.length - 1;
                    });
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'Bookmarks':
                        showBookmarksDialog();
                        break;
                      case 'History':
                        showHistoryDialog();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'Bookmarks',
                      child: ListTile(
                        leading: Icon(Icons.bookmark),
                        title: Text('Bookmarks'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'History',
                      child: ListTile(
                        leading: Icon(Icons.history),
                        title: Text('History'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.grey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Expanded(child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: _buildCurrentPage(),
                )),
                _buildBottomWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> onWillPop() async {
    if (await tabs[currentIndex].controller.canGoBack()) {
      tabs[currentIndex].controller.goBack();
      return Future.value(false);
    }
    return Future.value(true);
  }

  void loadUrl(String value) {
    Uri uri = Uri.parse(value);
    if (!uri.isAbsolute) {
      uri = Uri.parse("${searchEngineUrl}search?q=$value");
    }
    tabs[currentIndex].controller.loadRequest(uri);
    setState(() {
      tabs[currentIndex].url = uri.toString();
      textEditingController.text = uri.toString(); // Update the search bar with the current URL
    });
  }

  Widget _buildCurrentPage() {
    if (tabs[currentIndex].url == searchEngineUrl && currentIndex == tabs.length - 1) {
      return _buildHomePage();
    } else {
      return WebViewWidget(controller: tabs[currentIndex].controller);
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
              itemCount: speedDials.length + 1,
              itemBuilder: (context, index) {
                if (index == speedDials.length) {
                  return GestureDetector(
                    onTap: () async {
                      final url = await showAddSpeedDialDialog();
                      if (url != null) {
                        setState(() {
                          speedDials.add({
                            "title": Uri.parse(url).host,
                            "url": url,
                            "icon": "$url/favicon.ico",
                          });
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add, size: 50, color: Colors.grey),
                    ),
                  );
                } else {
                  return _buildSpeedDialItem(index);
                }
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
        int tabIndex = tabs.indexWhere((tab) => tab.url == url);
        if (tabIndex == -1) {
          setState(() {
            tabs.add(createNewTab(url));
            currentIndex = tabs.length - 1;
          });
        } else {
          setState(() {
            currentIndex = tabIndex;
          });
        }
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
              child: Image.network(
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
            Text(
              speedDials[index]['title']!,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
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
        const Text(
          'Shortcuts',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildShortcutButton('Bookmarks', Icons.bookmark, showBookmarksDialog),
            _buildShortcutButton('History', Icons.history, showHistoryDialog),
            _buildShortcutButton('Recent Tabs', Icons.tab, showTabSwitcherDialog),
          ],
        ),
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
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.black),
            onPressed: () {
              setState(() {
                tabs[currentIndex] = createNewTab(searchEngineUrl);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () async {
              if (await tabs[currentIndex].controller.canGoBack()) {
                tabs[currentIndex].controller.goBack();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.black),
            onPressed: () async {
              if (await tabs[currentIndex].controller.canGoForward()) {
                tabs[currentIndex].controller.goForward();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              tabs[currentIndex].controller.reload();
            },
          ),
        ],
      ),
    );
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Tabs',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.blueAccent),
                      onPressed: () {
                        setState(() {
                          tabs.add(createNewTab(searchEngineUrl));
                          currentIndex = tabs.length - 1;
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.redAccent),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 3 / 4,
                    ),
                    itemCount: tabs.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            currentIndex = index;
                          });
                          Navigator.of(context).pop();
                        },
                        onLongPress: () {
                          if (tabs.length > 1) {
                            setState(() {
                              tabs.removeAt(index);
                              if (currentIndex >= index && currentIndex > 0) {
                                currentIndex--;
                              }
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: index == currentIndex ? Colors.blueAccent.withOpacity(0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
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
                                      child: Icon(Icons.language, color: Colors.grey),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                getDomainName(tabs[index].url),
                                style: TextStyle(
                                  color: index == currentIndex ? Colors.blueAccent : Colors.black,
                                  fontWeight: index == currentIndex ? FontWeight.bold : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
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
          child: ListView(
            shrinkWrap: true,
            children: bookmarks.map((bookmark) {
              return ListTile(
                title: Text(bookmark),
                onTap: () {
                  Navigator.pop(context);
                  loadUrl(bookmark);
                },
              );
            }).toList(),
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
                title: Text(history[index]),
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
            onPressed: () {
              setState(() {
                history.clear();
              });
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

      currentIndex = tabs.length - 1;
      Get.to(()=>HomeScreen());
    });
  }

  void showForumsPage() {
    setState(() {
      tabs.add(createNewTab('https://forums.example.com')); // Replace with actual Forums page URL
      currentIndex = tabs.length - 1;
    });
  }
}
