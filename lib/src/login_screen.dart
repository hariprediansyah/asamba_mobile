import 'dart:convert';
import 'dart:developer';

import 'package:asamba_android/utils/loading_overlay.dart';
import 'package:asamba_android/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _passwordVisible = false;

  void login() async {
    String username = usernameController.text;
    String password = passwordController.text;

    loginNow(username, password);
  }

  void loginNow(username, password) async {
    LoadingOverlay.show(context);

    try {
      final body = {'UserName': username, 'Password': password};

      final response = await Util.apiPost(context, '/user/login', body);
      log(response.body);
      final resBody = jsonDecode(response.body);
      if (resBody['ok'] == true) {
        final data = resBody['data'];
        Util.putStringPreference(prefName, data['Name']);
        Util.putStringPreference(prefToken, data['accessToken']);
        Util.putStringPreference(prefUsername, data['UserName']);
        Util.putStringPreference(prefRole, data['RoleID'].toString());
        Util.putStringPreference(prefRoleName, data['RoleName'].toString());
        Util.putStringPreference(prefPassword, password);
        Util.putStringPreference(prefExpired, data['expiredToken'].toString());
        Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
      } else {
        Util.showNotif(context, resBody['message'], "Failed", isError: true);
      }
    } catch (e) {
      log(e.toString());
      Util.showNotif(context, "No internet connection", "Failed",
          isError: true);
    }
    LoadingOverlay.hide();
  }

  Future<void> _checkBiometrics() async {
    log("masuk 1");
    String? expiredTokenDate = Util.getStringPreference(prefExpired);
    log(expiredTokenDate);
    // return;
    if (expiredTokenDate != "" && expiredTokenDate != "null") {
      log("masuk 2");
      var expDate =
          DateTime.fromMillisecondsSinceEpoch(int.parse(expiredTokenDate!));
      log(expDate.toString());
      if (DateTime.now().isAfter(expDate)) {
        log("masuk");
        Util.putStringPreference(prefExpired, "");
        return;
      }
    } else {
      return;
    }
    bool canCheckBiometrics;
    try {
      log("masuk 3");
      canCheckBiometrics = await auth.canCheckBiometrics;
      log(canCheckBiometrics.toString());
      if (canCheckBiometrics) {
        bool authenticated = false;
        log("masuk 4");
        authenticated = await auth.authenticate(
          localizedReason: 'Pakai fingerprint atau kamera untuk login',
          options: const AuthenticationOptions(
            biometricOnly: true,
            useErrorDialogs: true,
            stickyAuth: true,
          ),
        );
        log("masuk biometrik");
        if (!mounted) return;

        if (authenticated) {
          loginNow(Util.getStringPreference(prefUsername),
              Util.getStringPreference(prefPassword));
        }
      }
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }

    if (!mounted) return;
  }

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Util.setScreenSize(screenWidth, screenHeight);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Util.dynamicSize(20)),
              child: Column(children: [
                SizedBox(height: Util.dynamicSize(30)),
                Text(
                  'Login to your account',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                SizedBox(height: Util.dynamicSize(30)),
                Image.asset('assets/images/vector_login.png'),
              ]),
            ),
          ),
          // Username field
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                // border: Border.all(color: colorScheme.onTertiary, width: 2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: Util.dynamicSize(20),
                  vertical: Util.dynamicSize(20)),
              child: Column(children: [
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline),
                    hintText: 'Username',
                    filled: true,
                    fillColor: Color.fromARGB(255, 234, 244, 255),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Util.dynamicSize(20)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: Util.dynamicSize(15)),

                // Password field
                TextFormField(
                  controller: passwordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    hintText: 'Password',
                    filled: true,
                    fillColor: Color.fromARGB(255, 234, 244, 255),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Util.dynamicSize(20)),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                        icon: Icon(_passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off)),
                  ),
                ),
                SizedBox(height: Util.dynamicSize(66)),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: Util.dynamicSize(50),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: login,
                    child: Text(
                      'Login',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                          fontSize: Util.dynamicSize(16)),
                    ),
                  ),
                ),
              ]),
            ),
          )
        ],
      ),
    );
  }
}
