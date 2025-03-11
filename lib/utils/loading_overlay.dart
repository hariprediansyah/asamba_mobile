import 'dart:developer';

import 'package:flutter/material.dart';

class LoadingOverlay {
  static OverlayEntry? _overlayEntry;
  static bool _isLoading = false;

  static void show(BuildContext context) {
    if (_isLoading) return; // Jika sudah ada overlay, jangan tambahkan lagi

    _isLoading = true;

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Background semi-transparan
            Container(
              color: Colors.black.withOpacity(0.5),
            ),
            // Spinner di tengah layar
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        );
      },
    );

    // Menambahkan overlay ke layar
    Overlay.of(context)?.insert(_overlayEntry!);
  }

  static void hide() {
    if (_isLoading && _overlayEntry != null) {
      _isLoading = false;
      _overlayEntry?.remove();
      _overlayEntry = null;
      // log("hide loading overlay", name: "LoadingOverlay");
    }
  }
}
