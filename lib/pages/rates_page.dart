import 'package:flutter/material.dart';
import 'package:kompovnet/data/mock_data.dart';

class RatesPage extends StatelessWidget {
  const RatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final offers = mockTariffs
        .where((tariff) => tariff.clubId == null || tariff.clubId == currentClub.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Тарифы: ${currentClub.name}'),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close_sharp),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: offer.isSpecial
                  ? const BorderSide(color: Colors.amber, width: 2)
                  : BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          offer.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: offer.isSpecial ? Colors.amber[800] : Colors.black,
                          ),
                        ),
                      ),
                      if (offer.isSpecial)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "ХИТ",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    offer.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const Divider(height: 24),
                  Text(
                    "Длительность: ${offer.duration}",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text("Время действия: ${offer.timeText}"),
                  const SizedBox(height: 8),
                  Text(
                    offer.price > 0 ? "${offer.price.toInt()} ₽" : "Почасовая оплата",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
