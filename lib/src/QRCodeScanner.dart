import 'dart:developer';

import 'package:asamba_android/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRCodeScanner extends StatefulWidget {
  const QRCodeScanner({super.key});

  @override
  State<QRCodeScanner> createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
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
        log("popped", name: "QRCodeScanner");
      }
    } catch (e) {
      log(e.toString(), name: "QRCodeScanner");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Util.setScreenSize(screenWidth, screenHeight);

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
                painter: ScannerOverlay(scanWindow: scanWindow),
                child: Container(), // Membuat overlay mengikuti layar
              );
            },
          ),
          // Tombol kembali di atas layar
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
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
              style: TextStyle(
                color: Colors.white,
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

// Overlay Painter untuk menambahkan area hitam transparan dan kotak hijau
class ScannerOverlay extends CustomPainter {
  const ScannerOverlay({
    required this.scanWindow,
    this.borderRadius = 12.0,
  });

  final Rect scanWindow; // Area pemindaian
  final double borderRadius; // Radius sudut

  @override
  void paint(Canvas canvas, Size size) {
    // Gambar latar belakang hitam dengan transparansi
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Gambar kotak hijau dengan radius
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

    // Warna latar belakang
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // Kombinasi latar belakang dan area kosong (cutout)
    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    // Border hijau untuk kotak
    final borderPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final borderRect = RRect.fromRectAndCorners(
      scanWindow,
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );

    // Gambar overlay hitam dengan cutout di tengah
    canvas.drawPath(backgroundWithCutout, backgroundPaint);

    // Gambar border hijau di area pemindaian
    canvas.drawRRect(borderRect, borderPaint);
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow ||
        borderRadius != oldDelegate.borderRadius;
  }
}
