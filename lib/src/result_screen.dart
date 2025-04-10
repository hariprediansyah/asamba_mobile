import 'package:asamba_android/src/home_screen.dart';
import 'package:asamba_android/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    final double amount;
    final String transactionTime;
    final String source;
    final String destination;
    final String transactionId;
    final String category;

    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    amount = double.parse(
        arguments['JumlahTransaksi'].toString().replaceAll(".0000", ""));
    transactionTime = arguments['created_at'];
    source = arguments['NamaUserAsal'];
    destination = arguments['NamaUserTujuan'];
    final formattedDate =
        DateFormat('MMddyyyyHHssmm').format(DateTime.parse(transactionTime));
    transactionId =
        "${formattedDate}${formattedDate.hashCode.toString().substring(0, formattedDate.hashCode.toString().length - 1)}";
    category = arguments['TipeTransaksi'];

    // Format untuk jumlah uang
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Transaction Result",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Card Rincian Transaksi
                    Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Provider dan ID
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Transaction",
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      transactionId,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue[500],
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Divider(
                                height: 1,
                                color: Colors.grey,
                                thickness: 1,
                                // style: DividerThemeData(
                                //   space: 1,
                                //   thickness: 1,
                                // ),
                              ),
                            ),

                            // Jumlah Uang
                            Text(
                              "${category == "TopUp" ? "+" : (category == "Pembayaran" || category == "Transfer") && Util.getStringPreference(prefRole) == "1" ? "+" : "-"} ${currencyFormat.format(amount)}",
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ID Transaksi
                            _buildDetailRow("Transaction ID", transactionId),

                            const SizedBox(height: 16),

                            // Dari
                            _buildDetailRow("From", source),

                            const SizedBox(height: 16),

                            _buildDetailRow("To", destination),

                            const SizedBox(height: 16),

                            // Tanggal dan waktu
                            _buildDetailRow(
                                "Transaction Time",
                                DateFormat("dd MMM yyyy, HH:mm:ss")
                                    .format(DateTime.parse(transactionTime))),

                            const SizedBox(height: 16),

                            // Catatan
                            _buildDetailRow("Status", "Success"),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Kategori Card
                    Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Text(
                              "Category",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: category == "TopUp"
                                    ? Colors.green[100]
                                    : (category == "Pembayaran" ||
                                                category == "Transfer") &&
                                            Util.getStringPreference(
                                                    prefRole) ==
                                                "1"
                                        ? Colors.green[100]
                                        : Colors.red[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                category == "TopUp"
                                    ? Icons.arrow_downward
                                    : (category == "Pembayaran" ||
                                                category == "Transfer") &&
                                            Util.getStringPreference(
                                                    prefRole) ==
                                                "1"
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                color: category == "TopUp"
                                    ? Colors.green[400]
                                    : (category == "Pembayaran" ||
                                                category == "Transfer") &&
                                            Util.getStringPreference(
                                                    prefRole) ==
                                                "1"
                                        ? Colors.green[400]
                                        : Colors.red[400],
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bagikan Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor, // Amber color
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Ok",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
