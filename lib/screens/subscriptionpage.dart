import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:lexibrowser/widgets/subscription_card.dart';
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
      }
    } on PlatformException catch (e) {
      // Handle platform exceptions here
      print("Platform Exception: $e");
    } catch (e) {
      // Handle other exceptions here
      print("Exception: $e");
    }
  }

  // Function to handle making a purchase
  void makePurchase(String selectedPackage) async {
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
        // Purchase successful, you can add your logic here
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

      body: Container(
        color: Colors.black,
        child: Center(
          child: ListView(
            children: <Widget>[
              SubscriptionCard(
                title: 'Monthly Pass',
                price: '\$10',
                description: 'Access to sports content for a month',
                onTap: () => makePurchase('Monthly Pass'),
              ),
              SizedBox(height: 20),
              SubscriptionCard(
                title: 'Six Months Pass',
                price: '\$20',
                description: 'Access to sports content for six months',
                onTap: () => makePurchase('Six Months Pass'),
              ),
              SizedBox(height: 20),
              SubscriptionCard(
                title: 'Season Pass',
                price: '\$40',
                description: 'Access to sports content for a year',
                onTap: () => makePurchase('Annual Pass'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
