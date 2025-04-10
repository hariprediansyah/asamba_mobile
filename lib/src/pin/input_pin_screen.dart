import 'dart:convert';
import 'dart:developer';

import 'package:asamba_android/src/app.dart';
import 'package:asamba_android/utils/loading_overlay.dart';
import 'package:asamba_android/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:pinput/pinput.dart';

class InputPinScreen extends StatefulWidget {
  @override
  _InputPinScreenState createState() => _InputPinScreenState();
}

class _InputPinScreenState extends State<InputPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  Uint8List? profileImageBytes;
  dynamic args = {};

  void loadGambar(String username) async {
    final Response? res =
        await Util.apiGetHit(context, "/user/Profile?UserName=" + username);

    if (res != null && res.statusCode == 200) {
      if (res.headers['content-type'] == 'image/png') {
        final Uint8List bytes = Uint8List.fromList(res.bodyBytes);

        setState(() {
          profileImageBytes = bytes;
        });
      } else {
        log('Failed to decode image: Unsupported content type');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadGambar(Util.getStringPreference(prefUsername));
  }

  void _onPinCompleted(String pin) async {
    final ok = await Util.Confirm(context, "Confirm transfer?");
    if (!ok) {
      setState(() {
        _pinController.text =
            _pinController.text.substring(0, _pinController.text.length - 1);
      });
      return;
    }
    LoadingOverlay.show(context);
    try {
      final dataBody = {
        "idHash": args["idHash"],
        "Nominal": args["amount"],
        "PIN": pin
      };
      final res =
          await Util.apiPost(context, "/trx/konfirmasiReqPembayaran", dataBody);
      final data = jsonDecode(res.body);
      LoadingOverlay.hide();
      if (data["ok"]) {
        _onSuccess();
      } else {
        Util.showNotif(context, data["message"], "Failed", isError: true);
      }
    } catch (e) {
      log(e.toString());
      Util.showNotif(
          context, "Something went wrong, please try again later", "Failed",
          isError: true);
    }
  }

  void _onSuccess() async {
    final dataHistoryApi = await Util.apiGet(
        context, '/trx/riwayat?start=1&limit=1&filter=&sortCol=&sortDir=');
    if (dataHistoryApi != null) {
      dynamic data = dataHistoryApi["data"][0];
      await Navigator.pushNamed(context, '/result', arguments: data);
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Util.setScreenSize(screenWidth, screenHeight);

    args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final customColors = Theme.of(context).extension<CustomColors>()!;

    final pinTheme = PinTheme(
      width: Util.dynamicSize(50),
      height: Util.dynamicSize(50),
      textStyle: TextStyle(
        fontSize: Util.dynamicSize(25),
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(Util.dynamicSize(8)),
        border: Border.all(
          color: Theme.of(context).inputDecorationTheme.hintStyle!.color!,
        ),
      ),
    );

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: profileImageBytes != null
                    ? MemoryImage(profileImageBytes!)
                    : AssetImage('assets/images/avatar.png'),
              ),
              SizedBox(height: Util.dynamicSize(16)),
              Text(
                "Hello, " + Util.getStringPreference(prefName),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: Util.dynamicSize(8)),
              Text(
                "Enter PIN to continue",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: Util.dynamicSize(32)),
              Pinput(
                controller: _pinController,
                length: 6,
                obscureText: true,
                keyboardType: TextInputType.number,
                enableSuggestions: false,
                autofillHints: const [],
                defaultPinTheme: pinTheme,
                focusedPinTheme: pinTheme.copyWith(
                  decoration: BoxDecoration(
                    color: customColors.pinBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: customColors.pinBorder,
                        width: Util.dynamicSize(2)),
                  ),
                ),
                onCompleted: _onPinCompleted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
