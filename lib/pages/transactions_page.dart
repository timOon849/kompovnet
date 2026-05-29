import 'package:flutter/material.dart';
import 'package:kompovnet/data/mock_data.dart';
import 'package:kompovnet/services/kompov_repository.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _reload();
  }

  Future<void> _reload() async {
    await KompovRepository.instance.refreshClientTransactions(currentClient.Id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("История операций"),
        backgroundColor: Colors.deepOrangeAccent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_sharp),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => _loadFuture = _reload()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          final tr = userTransactions;

          if (tr.isEmpty) {
            return const Center(child: Text("У вас пока нет операций"));
          }

          return ListView.builder(
            itemCount: tr.length,
            itemBuilder: (context, index) {
              final t = tr[index];
              final bool isWithdraw = t.isWithdraw;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      isWithdraw ? Colors.red[50] : Colors.green[50],
                  child: Icon(
                    isWithdraw ? Icons.remove : Icons.add,
                    color: isWithdraw ? Colors.red : Colors.green,
                  ),
                ),
                title: Text(t.Description),
                subtitle: Text(
                  "${t.CreatedAt.day}.${t.CreatedAt.month}.${t.CreatedAt.year}",
                ),
                trailing: Text(
                  "${isWithdraw ? '-' : '+'}${t.Amount.toInt()} ₽",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isWithdraw ? Colors.red : Colors.green,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
