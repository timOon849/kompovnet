import 'package:flutter/material.dart';
import 'package:kompovnet/data/mock_data.dart';
import 'package:kompovnet/services/kompov_repository.dart';

class RatesPage extends StatefulWidget {
  const RatesPage({super.key});

  @override
  State<RatesPage> createState() => _RatesPageState();
}

class _RatesPageState extends State<RatesPage> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _ensureTariffs();
  }

  Future<void> _ensureTariffs() async {
    if (clubTariffs.isEmpty) {
      await KompovRepository.instance.loadClubCatalog(currentClub.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Тарифы: ${currentClub.name}'),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_sharp),
        ),
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

          final offers = clubTariffs;
          if (offers.isEmpty) {
            return const Center(child: Text('Тарифы не найдены'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              offer.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (offer.isSpecial)
                            const Icon(Icons.star, color: Colors.amber),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(offer.description),
                      const SizedBox(height: 12),
                      Text(
                        offer.price == 0
                            ? '${offer.durationHours} ч. • по цене зоны'
                            : '${offer.durationHours} ч. • ${offer.price.toInt()} ₽',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
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
