import 'package:asamba_android/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmDialog extends StatelessWidget {
  ConfirmDialog(
      {super.key,
      required this.message,
      this.title = "Confirm",
      this.okButton = "Ok",
      this.cancelButton = "Back"});
  String title;
  final String message;
  String okButton;
  String cancelButton;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(Util.dynamicSize(16)),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(Util.dynamicSize(12))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/images/ic_circle_alert.png",
              width: Util.dynamicSize(24),
            ),
            SizedBox(height: Util.dynamicSize(16)),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: Util.dynamicSize(18),
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: Util.dynamicSize(8)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: Util.dynamicSize(14),
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface,
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
                  backgroundColor: Theme.of(context).colorScheme.primary,
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
            SizedBox(height: Util.dynamicSize(4)),
            SizedBox(
              width: double.infinity,
              height: Util.dynamicSize(48),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  cancelButton,
                  style: GoogleFonts.poppins(
                    fontSize: Util.dynamicSize(14),
                    color: Theme.of(context).colorScheme.onSurface,
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
