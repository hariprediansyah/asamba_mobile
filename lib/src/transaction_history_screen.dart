import 'dart:convert';
import 'package:asamba_android/src/app.dart';
import 'package:asamba_android/utils/loading_overlay.dart';
import 'package:asamba_android/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class TransactionHistoryScreen extends StatefulWidget {
  @override
  _TransactionHistoryScreenState createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<dynamic> _transactions = [];
  bool _isFirstLoad = true;
  String _filter = DateFormat('yyyy-MM').format(DateTime.now());
  bool _isLoading = false;
  late CustomColors customColors;

  Future<void> _loadData() async {
    if (_isFirstLoad) LoadingOverlay.show(context);
    try {
      final start = DateTime(int.parse(_filter.substring(0, 4)),
          int.parse(_filter.substring(5, 7)), 1);
      final end = DateTime(int.parse(_filter.substring(0, 4)),
              int.parse(_filter.substring(5, 7)) + 1, 1)
          .add(Duration(days: -1));

      final filter = _filter.isNotEmpty
          ? "&TanggalAwal=${DateFormat('yyyy-MM-dd').format(start)}&TanggalAkhir=${DateFormat('yyyy-MM-dd').format(end)}"
          : '';

      final response = await Util.apiGet(context,
          "/trx/riwayat?start=1&limit=500&filter=&sortCol=&sortDir=$filter");

      if (response != null) {
        final newTransactions = response['data'] ?? [];

        if (_isFirstLoad) {
          setState(() {
            _transactions = [];
            _isFirstLoad = false;
          });

          // Tambahkan item secara staggered pada load pertama
          _addItemsWithStaggeredAnimation(newTransactions);
        } else {
          // Jika sudah pernah load, gunakan animasi penuh
          _updateTransactionListWithStaggered(newTransactions);
        }
      }
    } catch (e) {
      print(e);
      Util.showNotif(context, e.toString(), "Failed", isError: true);
    }

    LoadingOverlay.hide();
  }

  void _addItemsWithStaggeredAnimation(List<dynamic> items) {
    // Tambahkan item dengan animasi staggered
    for (int i = 0; i < items.length; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted) {
          setState(() {
            _transactions.add(items[i]);
            if (_listKey.currentState != null) {
              _listKey.currentState!.insertItem(_transactions.length - 1);
            }
          });
        }
      });
    }
  }

  void _updateTransactionListWithStaggered(List<dynamic> newTransactions) {
    final List<dynamic> oldTransactions = List.from(_transactions);

    // Hapus item lama satu per satu dengan delay
    for (int i = oldTransactions.length - 1; i >= 0; i--) {
      final delayMs = (oldTransactions.length - 1 - i) * 50;
      Future.delayed(Duration(milliseconds: delayMs), () {
        if (mounted &&
            _listKey.currentState != null &&
            _transactions.isNotEmpty) {
          final itemToRemove = _transactions.removeLast();
          _listKey.currentState!.removeItem(
            _transactions.length,
            (context, animation) => _buildTransactionItem(
                customColors, context, itemToRemove, animation),
          );
        }
      });
    }

    // Setelah semua item lama dihapus, tambahkan yang baru dengan staggered
    int totalRemovalTime =
        oldTransactions.isEmpty ? 0 : oldTransactions.length * 50 + 300;
    Future.delayed(Duration(milliseconds: totalRemovalTime), () {
      if (mounted) {
        setState(() {
          _transactions = [];
        });
        _addItemsWithStaggeredAnimation(newTransactions);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      customColors = Theme.of(context).extension<CustomColors>()!;
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Transaction In ${DateFormat('MMM yyyy').format(DateTime.parse("$_filter-01"))}",
            style: GoogleFonts.poppins(
              fontSize: Util.dynamicSize(18),
              fontWeight: FontWeight.w500,
            )),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () async {
              final DateTime? pickedDate = await showMonthPicker(
                context: context,
                firstDate: DateTime(2022),
                lastDate: DateTime.now(),
                initialDate: _filter.isNotEmpty
                    ? DateTime.parse("$_filter-01")
                    : DateTime.now(),
              );

              if (pickedDate != null) {
                setState(() {
                  final year = pickedDate.year.toString();
                  final month = pickedDate.month < 10
                      ? "0${pickedDate.month}"
                      : pickedDate.month.toString();
                  _filter = "$year-$month";
                });
                _loadData();
              }
            },
          ),
        ],
      ),
      body: LiquidPullToRefresh(
        color: Theme.of(context).colorScheme.primary,
        animSpeedFactor: 3,
        showChildOpacityTransition: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        onRefresh: _loadData,
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: _isFirstLoad
              ? Container()
              : _transactions.isEmpty
                  ? Center(
                      child: Text(
                        "No Transactions Found",
                        style: GoogleFonts.poppins(
                          fontSize: Util.dynamicSize(16),
                          fontWeight: FontWeight.w500,
                          color: customColors.textTitleSmallDark,
                        ),
                      ),
                    )
                  : AnimatedList(
                      key: _listKey,
                      initialItemCount: _transactions.length,
                      itemBuilder: (context, index, animation) {
                        if (index >= _transactions.length) return SizedBox();
                        return _buildTransactionItem(customColors, context,
                            _transactions[index], animation);
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(CustomColors customColors, BuildContext context,
      dynamic transaction, Animation<double> animation) {
    final date = DateFormat("dd MMM yyyy HH:mm:ss")
        .format(DateTime.parse(transaction['WaktuTransaksi']));
    final amount = transaction['Nominal']
        .toString()
        .replaceAll(".00", "")
        .replaceAll(",", ".");
    final type = transaction['TipeTransaksi'];
    final color = type == "TopUp"
        ? Colors.green
        : (type == "Pembayaran" || type == "Transfer") &&
                Util.getStringPreference(prefRole) == "1"
            ? Colors.green
            : Colors.red;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeOut,
      )),
      child: FadeTransition(
        opacity: animation,
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, "/result", arguments: transaction);
          },
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      date,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: customColors.textTitleSmallDark,
                      ),
                    ),
                  ],
                ),
                Text(
                  (color == Colors.green ? "+Rp " : "-Rp ") + amount,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
