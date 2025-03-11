import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  bool processing = false;
  final MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );

  void _handleBarcode(BarcodeCapture barcodes) {
    try {
      final Barcode? result = barcodes.barcodes.firstOrNull;
      if (result != null && mounted && !processing) {
        Navigator.pop(context, result.rawValue);
        processing = true;
        log("popped", name: "ScanQRScreen");
      }
    } catch (e) {
      log(e.toString(), name: "ScanQRScreen");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ukuran kotak area pemindaian (scan window)
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: 300,
      height: 300,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // MobileScanner untuk membaca QR code
          MobileScanner(
            controller: controller,
            onDetect: _handleBarcode,
            scanWindow: scanWindow, // Tentukan area pemindaian
          ),
          // Overlay custom dengan kotak dan radius sudut
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, child) {
              return CustomPaint(
                painter:
                    ScannerOverlay(scanWindow: scanWindow, context: context),
                child: Container(), // Membuat overlay mengikuti layar
              );
            },
          ),
          // Tombol kembali di atas layar
          Positioned(
            top: 40,
            left: 16,
            child: TextButton.icon(
              label: Text("Scan QR",
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.surface,
                    fontSize: 18,
                  )),
              icon: Icon(Icons.chevron_left_rounded,
                  size: 30, color: Theme.of(context).colorScheme.surface),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Teks panduan di bawah layar
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Text(
              "Align the QR code within the frame",
              style: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.surface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class ScannerOverlay extends CustomPainter {
  const ScannerOverlay({
    required this.scanWindow,
    this.borderRadius = 0.0,
    required this.context,
    this.cornerLength = 30.0, // Length of corner edges
  });
  final BuildContext context;
  final Rect scanWindow; // Area pemindaian
  final double borderRadius; // Radius sudut
  final double cornerLength; // Panjang garis sudut

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          scanWindow,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      );

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final borderPaint = Paint()
      ..color = Theme.of(context).colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(backgroundWithCutout, backgroundPaint);

    // Draw corners only
    // Top-left corner
    canvas.drawLine(
      Offset(scanWindow.left, scanWindow.top + borderRadius),
      Offset(scanWindow.left, scanWindow.top + cornerLength),
      borderPaint,
    );
    canvas.drawLine(
      Offset(scanWindow.left + borderRadius, scanWindow.top),
      Offset(scanWindow.left + cornerLength, scanWindow.top),
      borderPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(scanWindow.right, scanWindow.top + borderRadius),
      Offset(scanWindow.right, scanWindow.top + cornerLength),
      borderPaint,
    );
    canvas.drawLine(
      Offset(scanWindow.right - borderRadius, scanWindow.top),
      Offset(scanWindow.right - cornerLength, scanWindow.top),
      borderPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(scanWindow.left, scanWindow.bottom - borderRadius),
      Offset(scanWindow.left, scanWindow.bottom - cornerLength),
      borderPaint,
    );
    canvas.drawLine(
      Offset(scanWindow.left + borderRadius, scanWindow.bottom),
      Offset(scanWindow.left + cornerLength, scanWindow.bottom),
      borderPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(scanWindow.right, scanWindow.bottom - borderRadius),
      Offset(scanWindow.right, scanWindow.bottom - cornerLength),
      borderPaint,
    );
    canvas.drawLine(
      Offset(scanWindow.right - borderRadius, scanWindow.bottom),
      Offset(scanWindow.right - cornerLength, scanWindow.bottom),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow ||
        borderRadius != oldDelegate.borderRadius;
  }
}
