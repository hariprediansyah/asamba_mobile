import 'package:asamba_android/src/localization/app_localizations.dart';
import 'package:asamba_android/src/login_screen.dart';
import 'package:asamba_android/src/home_screen.dart';
import 'package:asamba_android/src/payment_input_screen.dart';
import 'package:asamba_android/src/pin/create_pin_screen.dart';
import 'package:asamba_android/src/pin/input_pin_screen.dart';
import 'package:asamba_android/src/profile_screen.dart';
import 'package:asamba_android/src/result_screen.dart';
import 'package:asamba_android/src/scan_qr_screen.dart';
import 'package:asamba_android/src/show_qr_screen.dart';
import 'package:asamba_android/src/transaction_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'sample_feature/sample_item_details_view.dart';
import 'sample_feature/sample_item_list_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(
            inputDecorationTheme: InputDecorationTheme().copyWith(
              suffixIconColor: Color.fromARGB(255, 95, 159, 255),
              prefixIconColor: Color.fromARGB(255, 95, 159, 255),
              hintStyle: TextStyle(
                color: Color.fromARGB(255, 191, 215, 247),
              ),
            ),
            textTheme: TextTheme().copyWith(
                headlineLarge: GoogleFonts.poppins(
              color: Color.fromARGB(255, 30, 30, 30),
              fontWeight: FontWeight.w500,
              fontSize: 24,
            )),
            primaryColor: Color.fromARGB(255, 13, 110, 253),
            primaryColorDark: Color.fromARGB(255, 5, 69, 165),
            colorScheme: ColorScheme.light(
              primary: Color.fromARGB(255, 13, 110, 253),
              secondary: Color.fromARGB(255, 95, 159, 255),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Color.fromARGB(255, 13, 110, 253),
              foregroundColor: Colors.white,
            ),
            extensions: <ThemeExtension<dynamic>>[
              CustomColors(
                pinBackground: Color.fromARGB(255, 233, 242, 255),
                pinBorder: Color.fromARGB(255, 215, 230, 252),
                errorBackground: Color.fromARGB(255, 250, 243, 243),
                errorBorder: Color.fromARGB(255, 245, 192, 192),
                textTitleSmall: Color.fromARGB(255, 173, 173, 173),
                textTitleSmallDark: Color.fromARGB(255, 129, 129, 129),
              ),
            ],
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.blueGrey,
            colorScheme: ColorScheme.dark(
              primary: Colors.blueGrey,
              secondary: Colors.tealAccent,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.blueGrey,
              foregroundColor: Colors.white,
            ),
          ),
          themeMode: ThemeMode.light,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            return PageRouteBuilder(
              settings: routeSettings,
              pageBuilder: (context, animation, secondaryAnimation) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  case "/scan":
                    return ScanQRScreen();
                  case SampleItemListView.routeName:
                    return const SampleItemListView();
                  case '/':
                    return const LoginScreen();
                  case '/home':
                    return const HomeScreen();
                  case '/login':
                    return LoginScreen();
                  case "/create-pin":
                    return CreatePinScreen();
                  case "/pay":
                    return PaymentInputScreen();
                  case "/payment-success":
                    return ResultScreen();
                  case "/history":
                    return TransactionHistoryScreen();
                  case "/result":
                    return ResultScreen();
                  case "/input-pin":
                    return InputPinScreen();
                  case "/profile":
                    return ProfileScreen();
                  case "/show-qr":
                    return ShowQrScreen();
                  default:
                    return const LoginScreen();
                }
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                Offset begin;
                if (routeSettings.name == "/login" ||
                    routeSettings.name == "/scan") {
                  begin = const Offset(-1.0, 0.0); // Slide dari kiri ke kanan
                } else {
                  begin = const Offset(1.0, 0.0); // Slide dari kanan ke kiri
                }

                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            );
          },
        );
      },
    );
  }
}

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  final Color pinBorder;
  final Color pinBackground;
  final Color errorBorder;
  final Color errorBackground;
  final Color textTitleSmall;
  final Color textTitleSmallDark;

  const CustomColors({
    required this.pinBorder,
    required this.pinBackground,
    required this.errorBorder,
    required this.errorBackground,
    required this.textTitleSmall,
    required this.textTitleSmallDark,
  });

  @override
  CustomColors copyWith({Color? softBlue, Color? darkBlue}) {
    return CustomColors(
      pinBorder: pinBorder ?? this.pinBorder,
      pinBackground: pinBackground ?? this.pinBackground,
      errorBorder: errorBorder ?? this.errorBorder,
      errorBackground: errorBackground ?? this.errorBackground,
      textTitleSmall: textTitleSmall ?? this.textTitleSmall,
      textTitleSmallDark: textTitleSmallDark ?? this.textTitleSmallDark,
    );
  }

  @override
  CustomColors lerp(CustomColors? other, double t) {
    if (other == null) return this;
    return CustomColors(
      pinBorder: Color.lerp(pinBorder, other.pinBorder, t)!,
      pinBackground: Color.lerp(pinBackground, other.pinBackground, t)!,
      errorBorder: Color.lerp(errorBorder, other.errorBorder, t)!,
      errorBackground: Color.lerp(errorBackground, other.errorBackground, t)!,
      textTitleSmall: Color.lerp(textTitleSmall, other.textTitleSmall, t)!,
      textTitleSmallDark:
          Color.lerp(textTitleSmallDark, other.textTitleSmallDark, t)!,
    );
  }
}
