import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:lexibrowser/widgets/subscription_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lexibrowser/helpers/adhelper.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String? selectedPackage;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    fetchOfferings();
  }

  Future<void> initPlatformState() async {
    Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration = PurchasesConfiguration("");

    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration("goog_WkWvdkuPTNcYXemsFHzJlQXBQFo");
    }
    else if (Platform.isIOS) {
      configuration = PurchasesConfiguration("<revenuecat_project_apple_api_key>");
    }

    await Purchases.configure(configuration);
  }

  Future<void> fetchOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        // You can use the offerings here
      }
    } on PlatformException catch (e) {
      // Handle platform exceptions here
      print("Platform Exception: $e");
    } catch (e) {
      // Handle other exceptions here
      print("Exception: $e");
    }
  }

  Future<void> makePurchase(String selectedPackage) async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      Package? package;

      // Determine the package based on selectedPackage
      if (selectedPackage == "Monthly Pass") {
        package = offerings.current!.monthly;
      } else if (selectedPackage == "Six Months Pass") {
        package = offerings.current!.sixMonth;
      } else if (selectedPackage == "Annual Pass") {
        package = offerings.current!.annual;
      }

      if (package != null) {
        // Make the purchase
        await Purchases.purchasePackage(package);
        // Purchase successful, disable ads
        await AdHelper.setShowAds(false);
      } else {
        print("Package not found");
      }
    } catch (e) {
      // Handle purchase failure
      print("Purchase failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.keyboard_backspace_rounded)),
        title: const Text('Remove ads', style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 2.0,
        )),
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: ListView(
            children: <Widget>[
              SubscriptionCard(
                title: 'Monthly ',
                price: '\$10',
                description: 'Access to AD FREE content for a month',
                onTap: () => makePurchase('Monthly Pass'),
              ),
              SizedBox(height: 20),
              SubscriptionCard(
                title: 'Six Months',
                price: '\$20',
                description: 'Access to ADD FREE content for six months',
                onTap: () => makePurchase('Six Months Pass'),
              ),
              SizedBox(height: 20),
              SubscriptionCard(
                title: 'Yearly',
                price: '\$40',
                description: 'Access to AD FREE content for a year',
                onTap: () => makePurchase('Annual Pass'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
