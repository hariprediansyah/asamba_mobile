import 'package:asamba_android/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotifDialog extends StatelessWidget {
  NotifDialog(
      {super.key,
      required this.message,
      this.title,
      this.okButton = "Ok",
      this.isError = false});
  String? title;
  final String message;
  String okButton;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(Util.dynamicSize(16)),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Util.dynamicSize(12))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              isError
                  ? "assets/images/alert_red.png"
                  : "assets/images/alert_blue.png",
              // width: Util.dynamicSize(24),
              width: Util.dynamicSize(48),
            ),
            SizedBox(height: Util.dynamicSize(10)),
            Text(
              title ?? "Informasi",
              style: GoogleFonts.inter(
                fontSize: Util.dynamicSize(18),
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 16, 24, 40),
              ),
            ),
            SizedBox(height: Util.dynamicSize(16)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: Util.dynamicSize(14),
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(255, 16, 24, 40),
              ),
            ),
            SizedBox(height: Util.dynamicSize(24)),
            SizedBox(
              width: double.infinity,
              height: Util.dynamicSize(37),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isError
                      ? Color.fromARGB(255, 227, 26, 28)
                      : Color.fromARGB(255, 39, 58, 150),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  okButton,
                  style: GoogleFonts.poppins(
                    fontSize: Util.dynamicSize(14),
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
