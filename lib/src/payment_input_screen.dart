import 'dart:developer';
import 'dart:typed_data';

import 'package:asamba_android/src/app.dart';
import 'package:asamba_android/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class PaymentInputScreen extends StatefulWidget {
  @override
  State<PaymentInputScreen> createState() => _PaymentInputScreenState();
}

class _PaymentInputScreenState extends State<PaymentInputScreen> {
  final TextEditingController amountController = TextEditingController();
  final NumberFormat currencyFormat = NumberFormat("#,###", "id_ID");
  String? _name;
  Uint8List? profileImageBytes;

  @override
  void initState() {
    super.initState();
    amountController.text = "0";
  }

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
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Util.setScreenSize(screenWidth, screenHeight);

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    if (args != null) {
      _name = args["Name"];
      if (profileImageBytes == null) {
        loadGambar(args["UserName"]);
      }
    }

    CustomColors customColors = Theme.of(context).extension<CustomColors>()!;

    void _onKeyboardTap(String value) {
      String currentText =
          amountController.text.replaceAll(RegExp(r'[^0-9]'), "");

      int maxValue = 2147483647;
      int currentValue = int.parse(currentText);

      if (value == "⌫") {
        if (currentText.isNotEmpty) {
          currentText = currentText.substring(0, currentText.length - 1);
        }
      } else if (currentValue < maxValue) {
        currentText += value;
      }

      if (currentText.isEmpty) {
        currentText = "0";
      }

      String formattedValue = currencyFormat.format(int.parse(currentText));
      setState(() {
        amountController.text = "$formattedValue";
      });
    }

    Widget _buildKeyboardRow(List<String> keys) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: keys
            .map(
              (key) => Padding(
                padding: EdgeInsets.all(Util.dynamicSize(16)),
                child: TextButton(
                    onPressed: () => _onKeyboardTap(key),
                    child: Text(
                      key,
                      style: GoogleFonts.poppins(
                          color: customColors.textTitleSmallDark,
                          fontSize: Util.dynamicSize(20),
                          fontWeight: FontWeight.w500),
                    )),
              ),
            )
            .toList(),
      );
    }

    Widget _buildCustomKeyboard() {
      return Column(
        children: [
          _buildKeyboardRow(["1", "2", "3"]),
          _buildKeyboardRow(["4", "5", "6"]),
          _buildKeyboardRow(["7", "8", "9"]),
          _buildKeyboardRow(["", "0", "⌫"]),
        ],
      );
    }

    void transfer() async {
      Navigator.pushNamed(context, "/input-pin", arguments: {
        "amount": amountController.text.replaceAll(RegExp(r'[^0-9]'), ""),
        "name": _name,
        "idHash": args["idHash"]
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.chevron_left,
                size: Util.dynamicSize(30),
                color: Theme.of(context).textTheme.headlineLarge!.color,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            Text(
              "Transfer",
              style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.headlineLarge!.color,
                  fontSize: Util.dynamicSize(18),
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(Util.dynamicSize(20)),
        child: Column(
          children: [
            SizedBox(height: Util.dynamicSize(20)),
            CircleAvatar(
              radius: 40,
              backgroundImage: profileImageBytes != null
                  ? MemoryImage(profileImageBytes!)
                  : AssetImage('assets/images/avatar.png'),
            ),
            SizedBox(height: Util.dynamicSize(16)),
            Text(
              _name ?? "Penjual",
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: Util.dynamicSize(25)),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                "Rp ",
                style: GoogleFonts.poppins(
                  fontSize: Util.dynamicSize(24),
                  color: Theme.of(context).primaryColorDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                amountController.text,
                key: ValueKey<String>(amountController
                    .text), // Biar animasi aktif setiap perubahan teks
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: Util.dynamicSize(24),
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ]),
            SizedBox(height: Util.dynamicSize(60)),
            _buildCustomKeyboard(),
            Spacer(),
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
                onPressed: transfer,
                child: Text(
                  'Transfer',
                  style: TextStyle(
                      fontSize: Util.dynamicSize(16), color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
