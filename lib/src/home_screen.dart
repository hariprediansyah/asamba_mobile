import 'dart:developer';

import 'package:asamba_android/src/app.dart';
import 'package:asamba_android/utils/util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    initializeFirebase();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) {
    //     Navigator.of(context).pushNamed('/login');
    //   }
    // });
  }

  Future<void> initializeFirebase() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    log('FCM Token: $fcmToken');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Util.setScreenSize(screenWidth, screenHeight);
    CustomColors customColors = Theme.of(context).extension<CustomColors>()!;

    Widget _historyItem(String title, String date, String amount, Color color) {
      return Padding(
        padding: EdgeInsets.only(bottom: Util.dynamicSize(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: Util.dynamicSize(14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.poppins(
                    fontSize: Util.dynamicSize(12),
                    color: customColors.textTitleSmallDark,
                  ),
                ),
              ],
            ),
            Text(
              amount,
              style: GoogleFonts.poppins(
                fontSize: Util.dynamicSize(14),
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    Future<void> refreshData() async {
      await Future.delayed(const Duration(seconds: 4));
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.of(context).pushNamed('/scan');
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, size: Util.dynamicSize(32), color: Colors.white),
      ),
      body: LiquidPullToRefresh(
        onRefresh: refreshData,
        color: Theme.of(context).colorScheme.primary,
        animSpeedFactor: 3,
        showChildOpacityTransition: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Util.dynamicSize(26),
                  vertical: Util.dynamicSize(27)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage('assets/images/avatar.png'),
                      ),
                      SizedBox(width: Util.dynamicSize(10)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi, Wikun Kertanegara",
                            style: GoogleFonts.poppins(
                              fontSize: Util.dynamicSize(16),
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Text(
                            "Pembeli",
                            style: GoogleFonts.poppins(
                              fontSize: Util.dynamicSize(13),
                              color: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .color,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: Util.dynamicSize(58)),
                  Text("Balance",
                      style: GoogleFonts.poppins(
                          fontSize: Util.dynamicSize(15),
                          color: customColors.textTitleSmall)),
                  Text(
                    "Rp. 76.265",
                    style: GoogleFonts.poppins(
                      fontSize: Util.dynamicSize(38),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: Util.dynamicSize(60)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Last history",
                        style: GoogleFonts.poppins(
                            fontSize: Util.dynamicSize(15),
                            color: customColors.textTitleSmall),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "All History >",
                              style: GoogleFonts.poppins(
                                fontSize: Util.dynamicSize(15),
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            // Icon(
                            //   Icons.chevron_right_rounded,
                            //   size: 28,
                            //   color: Theme.of(context).colorScheme.primary,
                            // ),
                          ])
                    ],
                  ),
                  SizedBox(height: Util.dynamicSize(10)),
                  ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      _historyItem("Transaction", "10 Feb 2025 11:02",
                          "- Rp. 15.000", Colors.red),
                      _historyItem("Transaction", "11 Feb 2025 14:23",
                          "- Rp. 15.000", Colors.red),
                      _historyItem("Transfer", "10 Feb 2025 19:08",
                          "+ Rp. 76.000", Colors.green),
                      _historyItem("Transfer", "10 Feb 2025 19:08",
                          "+ Rp. 76.000", Colors.green),
                      _historyItem("Transaction", "11 Feb 2025 14:23",
                          "- Rp. 15.000", Colors.red),
                      _historyItem("Transaction", "11 Feb 2025 14:23",
                          "- Rp. 15.000", Colors.red),
                      _historyItem("Transaction", "11 Feb 2025 14:23",
                          "- Rp. 15.000", Colors.red),
                      _historyItem("Transaction", "11 Feb 2025 14:23",
                          "- Rp. 15.000", Colors.red),
                      _historyItem("Transaction", "11 Feb 2025 14:23",
                          "- Rp. 15.000", Colors.red),
                      _historyItem("Transaction", "11 Feb 2025 14:23",
                          "- Rp. 15.000", Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
