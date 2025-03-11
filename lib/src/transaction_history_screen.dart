import 'package:flutter/material.dart';

class TransactionHistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> transactions = [
    {"date": "10 Feb 2025", "amount": "- Rp. 15.000", "type": "Transaction"},
    {"date": "11 Feb 2025", "amount": "+ Rp. 76.000", "type": "Transfer"},
    {"date": "12 Feb 2025", "amount": "- Rp. 20.000", "type": "Transaction"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Transaction History")),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(transactions[index]['type']),
            subtitle: Text(transactions[index]['date']),
            trailing: Text(
              transactions[index]['amount'],
              style: TextStyle(
                  color: transactions[index]['amount'].contains("-")
                      ? Colors.red
                      : Colors.green),
            ),
          );
        },
      ),
    );
  }
}
