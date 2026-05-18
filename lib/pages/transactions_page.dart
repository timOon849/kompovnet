import 'package:flutter/material.dart';
import 'package:kompovnet/data/mock_data.dart';
import 'package:kompovnet/data/transaction.dart';
class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = userTransactions
        .where((u) => u.userId == currentUser.Id)
        .toList()
        .reversed
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("История операций"),
        backgroundColor: Colors.deepOrangeAccent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close_sharp),
        ),
      ),
      body: tr.isEmpty
          ? const Center(child: Text("У вас пока нет операций"))
          : ListView.builder(
              itemCount: tr.length,
              itemBuilder: (context, index) {
                final t = tr[index];
                final bool isWithdraw = t.type == TransactionType.withdraw;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isWithdraw ? Colors.red[50] : Colors.green[50],
                    child: Icon(
                      isWithdraw ? Icons.remove : Icons.add,
                      color: isWithdraw ? Colors.red : Colors.green,
                    ),
                  ),
                  title: Text(t.description),
                  subtitle: Text(
                    "${t.date.day}.${t.date.month}.${t.date.year} ${t.date.hour}:${t.date.minute.toString().padLeft(2, '0')}",
                  ),
                  trailing: Text(
                    "${isWithdraw ? '-' : '+'}${t.amount.toInt()} ₽",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isWithdraw ? Colors.red : Colors.green,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
