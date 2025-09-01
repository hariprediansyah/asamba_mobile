import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:asamba_android/src/app.dart';
import 'package:asamba_android/utils/loading_overlay.dart';
import 'package:asamba_android/utils/util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Uint8List? profileImageBytes;
  String balance = "0";
  List<dynamic> dataHistory = [];

  @override
  void initState() {
    super.initState();
    initializeFirebase();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      LoadingOverlay.show(context);
      FirebaseMessaging.instance.requestPermission();
      loadData();
    });
  }

  Future<void> loadData() async {
    checkPin();
    try {
      final Response? res = await Util.apiGetHit(context,
          "/user/Profile?UserName=" + Util.getStringPreference(prefUsername));

      if (res != null && res.statusCode == 200) {
        if (res.headers['content-type'] == 'image/png') {
          final Uint8List bytes = Uint8List.fromList(res.bodyBytes);

          setState(() {
            profileImageBytes = bytes; // Simpan di memory
          });
        } else {
          log('Failed to decode image: Unsupported content type');
        }
      }
      final dataBalance = await Util.apiGet(context, '/user/saldo');
      if (dataBalance != null) {
        setState(() {
          balance = dataBalance["Saldo"]
              .toString()
              .replaceAll(".00", "")
              .replaceAll(",", ".");
        });
      }

      final dataHistoryApi = await Util.apiGet(
          context, '/trx/riwayat?start=1&limit=5&filter=&sortCol=&sortDir=');
      if (dataHistoryApi != null) {
        setState(() {
          dataHistory = dataHistoryApi["data"];
        });
      }
    } catch (e) {
      log(e.toString());
    }
    LoadingOverlay.hide();
  }

  Future<void> checkPin() async {
    try {
      final data = await Util.apiGetBody(context, '/user/hasPIN');
      if (data != null) {
        if (!data["ok"]) {
          LoadingOverlay.hide();
          Navigator.pushNamedAndRemoveUntil(
              context, "/create-pin", (route) => false);
        }
      }
    } catch (e) {
      log(e.toString());
      Util.showNotif(
          context, "Something went wrong, please try again later", "Failed",
          isError: true);
    }
  }

  Future<void> initializeFirebase() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    log('FCM Token: $fcmToken');
    Util.apiPost(context, "/user/tokenAndroid", {"TokenAndroid": fcmToken});
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
              (color == Colors.green ? "+Rp " : "-Rp ") + amount,
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
      await loadData();
    }

    Future<void> handleScanQr() async {
      final result = await Navigator.of(context).pushNamed('/scan');
      print(result);
      if (result != null) {
        LoadingOverlay.show(context);
        try {
          final res = await Util.apiPost(
              context, '/trx/reqPembayaran', {"idHash": result});
          if (res.statusCode == 200) {
            final data = jsonDecode(res.body);
            if (data["ok"]) {
              data["data"]["idHash"] = result;
              Navigator.pushNamed(context, "/pay", arguments: data["data"]);
            } else {
              Util.showNotif(context, data["message"], "Failed", isError: true);
            }
          } else {
            Util.showNotif(context,
                "Something went wrong, please try again later", "Failed",
                isError: true);
          }
        } catch (e) {
          log(e.toString());
          Util.showNotif(
              context, "Something went wrong, please try again later", "Failed",
              isError: true);
        }
        LoadingOverlay.hide();
      }
    }

    Future<void> handleShowQr() async {
      await Navigator.of(context).pushNamed('/show-qr');
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 0,
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: Util.getStringPreference(prefRole) == "1"
            ? handleShowQr
            : handleScanQr,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.qr_code_scanner_rounded,
            size: Util.dynamicSize(32), color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: EdgeInsets.symmetric(
                horizontal: Util.dynamicSize(26),
                vertical: Util.dynamicSize(27)),
            child: Row(
              children: [
                GestureDetector(
                  // onTap: () => Navigator.pushNamed(context, "/profile"),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: profileImageBytes != null
                        ? Image.memory(profileImageBytes!).image
                        : Image.asset('assets/images/avatar.png').image,
                  ),
                ),
                SizedBox(width: Util.dynamicSize(10)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi, " + Util.getStringPreference(prefName),
                      style: GoogleFonts.poppins(
                        fontSize: Util.dynamicSize(16),
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    Text(
                      Util.getStringPreference(prefRoleName),
                      style: GoogleFonts.poppins(
                        fontSize: Util.dynamicSize(13),
                        color: Theme.of(context)
                            .colorScheme
                            .surface
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.white),
                  onPressed: () async {
                    final ok = await Util.Confirm(context, "Logout?");
                    if (ok) {
                      Util.putStringPreference(prefToken, "");
                      Util.putStringPreference(prefExpired, "");
                      Navigator.pushNamedAndRemoveUntil(
                          context, "/login", (route) => false);
                    }
                  },
                ),
              ],
            ),
          ),
          LiquidPullToRefresh(
            onRefresh: refreshData,
            color: Theme.of(context).colorScheme.primary,
            animSpeedFactor: 3,
            showChildOpacityTransition: false,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: Util.dynamicSize(26)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Util.dynamicSize(48)),
                      Text("Balance",
                          style: GoogleFonts.poppins(
                              fontSize: Util.dynamicSize(15),
                              color: customColors.textTitleSmall)),
                      Text(
                        "Rp " + balance,
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
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    "/history",
                                  ),
                                  child: Text(
                                    "All History >",
                                    style: GoogleFonts.poppins(
                                      fontSize: Util.dynamicSize(15),
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
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
                        children: dataHistory
                            .map((e) => _historyItem(
                                e['TipeTransaksi'],
                                e['WaktuTransaksi'],
                                e['Nominal']
                                    .toString()
                                    .replaceAll(".00", "")
                                    .replaceAll(",", "."),
                                e['TipeTransaksi'] == "TopUp"
                                    ? Colors.green
                                    : (e['TipeTransaksi'] == "Pembayaran" ||
                                                e['TipeTransaksi'] ==
                                                    "Transfer") &&
                                            Util.getStringPreference(
                                                    prefRole) ==
                                                "1"
                                        ? Colors.green
                                        : Colors.red))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
