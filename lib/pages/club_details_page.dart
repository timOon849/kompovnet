import 'package:flutter/material.dart';
import 'package:kompovnet/data/computer.dart';
import 'package:kompovnet/data/computer_status.dart';
import 'package:kompovnet/data/game_zone.dart';
import 'package:kompovnet/data/mock_data.dart';
import 'package:kompovnet/services/kompov_repository.dart';

class ClubDetailsPage extends StatefulWidget {
  const ClubDetailsPage({super.key});

  @override
  State<ClubDetailsPage> createState() => _ClubDetailsPageState();
}

class _ClubDetailsPageState extends State<ClubDetailsPage> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _ensureCatalog();
  }

  Future<void> _ensureCatalog() async {
    if (clubZones.isEmpty || clubComputers.isEmpty) {
      await KompovRepository.instance.loadClubCatalog(currentClub.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('О клубе'),
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent,
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

          final zones = clubZones;
          final computers = clubComputers;
          final freeComputers = computers
              .where((pc) => pc.Status == ComputerStatus.free)
              .length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentClub.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(currentClub.description),
                      const SizedBox(height: 16),
                      _InfoLine(icon: Icons.place, text: currentClub.address),
                      _InfoLine(
                        icon: Icons.schedule,
                        text: currentClub.workTime,
                      ),
                      if (currentClub.phone.isNotEmpty)
                        _InfoLine(icon: Icons.phone, text: currentClub.phone),
                      const SizedBox(height: 12),
                      Text(
                        'Свободных ПК: $freeComputers из ${computers.length}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Игровые зоны',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...zones.map((zone) => _ZoneCard(zone: zone, computers: computers)),
            ],
          );
        },
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final GameZone zone;
  final List<Computer> computers;

  const _ZoneCard({required this.zone, required this.computers});

  @override
  Widget build(BuildContext context) {
    final zoneComputers =
        computers.where((pc) => pc.ZoneId == zone.id).toList();
    final freeInZone = zoneComputers
        .where((pc) => pc.Status == ComputerStatus.free)
        .length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              zone.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(zone.description),
            const SizedBox(height: 8),
            Text('${zone.pricePerHour.toInt()} ₽/час'),
            Text('Свободно: $freeInZone / ${zoneComputers.length} ПК'),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
