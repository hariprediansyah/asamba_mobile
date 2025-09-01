import 'dart:convert';
import 'dart:developer';

import 'package:asamba_android/src/components/confirm_dialog.dart';
import 'package:asamba_android/src/components/notif_dialog.dart';
import 'package:asamba_android/src/login_screen.dart';
import 'package:asamba_android/utils/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

String prefToken = "token";
String prefExpired = "expired";
String prefName = "name";
String prefUsername = "username";
String prefPassword = "password";
String prefRole = "role";
String prefRoleName = "roleName";

const int widthConst = 360;
const int heightConst = 800;

class Util {
  static double screenWidth = 0;
  static double screenHeight = 0;
  static SharedPreferences? preferences;

  static getURL() {
    // return "https://7xb33xt1-5960.asse.devtunnels.ms";
    return "https://api.asamba.id";
  }

  static String getToken() {
    return "Bearer ${Util.getStringPreference(prefToken)}";
  }

  static Future<void> initializePreferences() async {
    preferences = await SharedPreferences.getInstance();
  }

  static String getStringPreference(String key) {
    return preferences!.getString(key) ?? "";
  }

  static bool getBoolPreference(String key) {
    return preferences!.getBool(key) ?? false;
  }

  static void putBoolPreference(String key, bool value) {
    preferences!.setBool(key, value);
  }

  static void putStringPreference(String key, String value) {
    preferences!.setString(key, value);
  }

  static void setScreenSize(double width, double height) {
    screenWidth = width;
    screenHeight = height;
  }

  static double dynamicSize(double size, [bool isHeight = false]) {
    if (!isHeight) {
      return screenWidth * (size / widthConst);
    } else {
      if (screenHeight < heightConst) {
        if (size < (heightConst - screenHeight)) {
          return 0;
        }
        return size - (heightConst - screenHeight);
      }
      return screenHeight - heightConst + size;
    }
  }

  static Future<void> showNotif(
      BuildContext context, String message, String? title,
      {bool isError = false}) async {
    await showDialog(
      context: context,
      builder: (ctx) =>
          NotifDialog(message: message, title: title, isError: isError),
    );
  }

  static Future<http.Response> apiPost(
      BuildContext context, String url, Map<String, dynamic> body) async {
    log(url);
    log(body.toString());
    final response = await http.post(Uri.parse(Util.getURL() + url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${Util.getStringPreference(prefToken)}",
        },
        body: jsonEncode(body));
    if (response.statusCode == 401) {
      Navigator.pushAndRemoveUntil(
        context,
        new MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    }
    return response;
  }

  static Future<http.Response> apiPut(
      BuildContext context, String url, Map<String, dynamic>? body) async {
    final response = await http.put(Uri.parse(Util.getURL() + url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${Util.getStringPreference(prefToken)}",
        },
        body: jsonEncode(body));
    if (response.statusCode == 401) {
      Navigator.pushAndRemoveUntil(
        context,
        new MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    }
    return response;
  }

  static Future<http.Response?> apiGetHit(
      BuildContext context, String url) async {
    log(url);
    try {
      final response = await http.get(Uri.parse(Util.getURL() + url), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${Util.getStringPreference(prefToken)}"
      });

      if (response.statusCode == 401) {
        Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      }

      if (response.statusCode != 200) {
        // LoadingOverlay.hide();
        // showNotif(context, response.body, "Failed", isError: true);
        return null;
      } else {
        return response;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<dynamic> apiGetBody(BuildContext context, String url) async {
    log(url);
    try {
      final response = await http.get(Uri.parse(Util.getURL() + url), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${Util.getStringPreference(prefToken)}"
      });

      if (response.statusCode == 401) {
        Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      }

      if (response.statusCode != 200) {
        // LoadingOverlay.hide();
        showNotif(context, response.body, "Failed", isError: true);
        print(response.body);
        return null;
      } else {
        var data = jsonDecode(response.body);
        log(data.toString());
        return data;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<dynamic> apiGet(BuildContext context, String url) async {
    log(url);
    // LoadingOverlay.show(context);
    try {
      final response = await http.get(Uri.parse(Util.getURL() + url), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${Util.getStringPreference(prefToken)}"
      });

      if (response.statusCode == 401) {
        LoadingOverlay.hide();
        Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
        return null;
      }

      if (response.statusCode != 200) {
        // LoadingOverlay.hide();
        showNotif(
            context, "Something went wrong, please try again later", "Failed",
            isError: true);
        return null;
      } else {
        var data = jsonDecode(response.body);
        log(data.toString());
        if (data['ok'] == true) {
          return data['data'];
        } else {
          // showAnimatedToast(context, data['Message'].toString(), isError: true);
          showNotif(context, data['message'].toString(), "Failed",
              isError: true);
          // LoadingOverlay.hide();
          log(data['message'].toString());
          return null;
        }
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  static Future<bool> Confirm(context, String message,
      {String title = "Konfirmasi",
      String okButton = "Ok",
      String cancelButton = "Kembali"}) async {
    final respon = await showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        message: message,
        okButton: okButton,
        cancelButton: cancelButton,
        title: title,
      ),
    );
    return respon ?? false;
  }
}
