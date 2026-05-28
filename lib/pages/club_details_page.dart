import 'package:flutter/material.dart';
import 'package:kompovnet/data/computer.dart';
import 'package:kompovnet/data/game_zone.dart';
import 'package:kompovnet/data/mock_data.dart';

class ClubDetailsPage extends StatelessWidget {
  const ClubDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final zones = mockZones.where((zone) => zone.clubId == currentClub.id).toList();
    final computers = mockComputers.where((pc) => pc.ClubId == currentClub.id).toList();
    final freeComputers = computers.where((pc) => pc.Status == ComputerStatus.free).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('О клубе'),
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentClub.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(currentClub.description),
                  const SizedBox(height: 16),
                  _InfoLine(icon: Icons.place, text: currentClub.address),
                  _InfoLine(icon: Icons.schedule, text: currentClub.workTime),
                  _InfoLine(icon: Icons.phone, text: currentClub.phone),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Всего ПК',
                  value: computers.length.toString(),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Свободно',
                  value: freeComputers.toString(),
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Игровые зоны',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          for (final zone in zones) _ZoneCard(zone: zone),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrangeAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () => Navigator.pushNamed(context, '/booking'),
            icon: const Icon(Icons.computer),
            label: const Text('Перейти к бронированию'),
          ),
        ],
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final GameZone zone;

  const _ZoneCard({required this.zone});

  @override
  Widget build(BuildContext context) {
    final zoneComputers = mockComputers.where((pc) => pc.ZoneId == zone.id).toList();
    final freeComputers = zoneComputers.where((pc) => pc.Status == ComputerStatus.free).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.videogame_asset, color: zone.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    zone.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Text('${zone.pricePerHour.toInt()} ₽/ч'),
              ],
            ),
            const SizedBox(height: 8),
            Text(zone.description),
            const SizedBox(height: 8),
            Text('ПК: ${zoneComputers.length}, свободно: $freeComputers'),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.deepOrangeAccent),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(title),
        ],
      ),
    );
  }
}
