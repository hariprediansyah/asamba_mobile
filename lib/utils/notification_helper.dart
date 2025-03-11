import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final _notification = FlutterLocalNotificationsPlugin();
  static late GlobalKey<NavigatorState> _navigatorKey;

  // Inisialisasi notifikasi
  static init(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _notification.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        log("Payload: ${response.payload}");
        if (response.payload != null) {
          _navigateToScreen(response.payload!); // Navigasi ke screen tertentu
        }
      },
    );
  }

  // Menampilkan notifikasi
  static pushNotification({
    required String title,
    required String body,
    required Map<String, dynamic>
        payload, // Tambahkan payload untuk menentukan screen tujuan
  }) async {
    var androidDetails = AndroidNotificationDetails(
      "fcm_default_channel",
      "fcm_default_channel",
      importance: Importance.max,
      priority: Priority.high,
    );
    var iosDetails = DarwinNotificationDetails();

    var notificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    log(payload.toString());
    await _notification.show(
      100, // ID notifikasi
      title,
      body,
      notificationDetails,
      payload: payload.toString(), // Menyimpan informasi untuk navigasi
    );
  }

  // Navigasi ke screen tertentu berdasarkan payload
  static void _navigateToScreen(String payload) {
    try {
      final context = _navigatorKey.currentContext;
      log("Payload 2: $payload");
      payload = payload.substring(1, payload.length - 1);
      List<String> pairs = payload.split(', ');
      Map<String, dynamic> data = {
        for (var pair in pairs) pair.split(': ')[0]: pair.split(': ')[1]
      };

      log(data.toString());
      if (context != null) {
        // if (data["type"] == "SOS") {
        //   Navigator.pushAndRemoveUntil(
        //       context,
        //       MaterialPageRoute(
        //           builder: (context) => LaporanDetailInsiden(
        //                 id: int.parse(data['id']),
        //                 fromNotif: true,
        //               )),
        //       (route) => false);
        // } else {
        //   print("Payload tidak dikenal: $payload");
        // }
      } else {
        print("Context null");
      }
    } catch (e) {
      log(e.toString());
    }
  }
}

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationHelper {
//   static final _notification = FlutterLocalNotificationsPlugin();

//   static init() {
//     _notification.initialize(
//       InitializationSettings(
//           android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//           iOS: DarwinInitializationSettings()),
//     );
//   }

//   static pushNotification(
//       {required String title, required String body, Function? callback}) async {
//     var androidDetails = AndroidNotificationDetails(
//         "fcm_default_channel", "fcm_default_channel",
//         importance: Importance.max, priority: Priority.high);
//     var iosDetails = DarwinNotificationDetails();
//     print(title);
//     print(body);

//     var notificationDetails =
//         NotificationDetails(android: androidDetails, iOS: iosDetails);
//     await _notification.show(100, title, body, notificationDetails);
//   }
// }
