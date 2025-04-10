import 'dart:convert';
import 'dart:developer';

import 'package:asamba_android/src/app.dart';
import 'package:asamba_android/utils/loading_overlay.dart';
import 'package:asamba_android/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:pinput/pinput.dart';

class CreatePinScreen extends StatefulWidget {
  @override
  _CreatePinScreenState createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  bool _isConfirm = false;
  bool _isError = false;
  String savedPin = '';
  final TextEditingController _pinController = TextEditingController();
  Uint8List? profileImageBytes;

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
    if (!_isConfirm) {
      savedPin = pin;
      _pinController.text = '';
      setState(() {
        _isConfirm = true;
      });
    } else {
      if (pin == savedPin) {
        // Navigator.pushNamed(context, "/home");
        LoadingOverlay.show(context);
        try {
          final res =
              await Util.apiPost(context, "/user/CreatePIN", {"PIN": pin});
          final data = jsonDecode(res.body);
          LoadingOverlay.hide();
          if (data["ok"]) {
            await Util.showNotif(context, "Pin berhasil dibuat", "Success");
            Navigator.pushNamedAndRemoveUntil(
                context, "/home", (route) => false);
          } else {
            Util.showNotif(context, data["message"], "Failed", isError: true);
          }
        } catch (e) {
          log(e.toString());
          Util.showNotif(
              context, "Something went wrong, please try again later", "Failed",
              isError: true);
        }
      } else {
        setState(() {
          _isError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Util.setScreenSize(screenWidth, screenHeight);

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
        color: _isError
            ? customColors.errorBackground
            : Theme.of(context).colorScheme.surface, // Warna background
        borderRadius: BorderRadius.circular(Util.dynamicSize(8)),
        border: Border.all(
            color: _isError
                ? customColors.errorBorder
                : Theme.of(context).inputDecorationTheme.hintStyle!.color!),
      ),
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (_isConfirm) {
          setState(() {
            _isConfirm = false;
            _isError = false;
            _pinController.text = '';
          });
          return;
        } else {
          if (Navigator.of(context).canPop()) {
            Navigator.pop(context);
          }
          log("pop", name: "CreatePinScreen");
        }
        // Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      },
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Padding(
            key: ValueKey<bool>(_isConfirm),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: profileImageBytes != null
                      ? MemoryImage(profileImageBytes!)
                      : AssetImage(
                          'assets/images/avatar.png'), // Ganti dengan gambar profil
                ),
                SizedBox(height: Util.dynamicSize(16)),
                Text(
                  "Hello, " + Util.getStringPreference(prefName),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: Util.dynamicSize(8)),
                AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: Text(
                      key: ValueKey<bool>(_isConfirm),
                      _isConfirm ? "Confirm PIN" : "Create PIN to continue",
                      style: Theme.of(context).textTheme.bodyMedium,
                    )),
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
                  onChanged: (value) => setState(() => _isError = false),
                ),
                AnimatedOpacity(
                    opacity: _isError ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: EdgeInsets.only(top: Util.dynamicSize(5)),
                      child: Text(
                        "PIN does not match",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
