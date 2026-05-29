import 'package:flutter/material.dart';
import 'package:kompovnet/data/computer_club.dart';
import 'package:kompovnet/data/mock_data.dart';
import 'package:kompovnet/services/kompov_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClubSelectionPage extends StatefulWidget {
  const ClubSelectionPage({super.key});

  @override
  State<ClubSelectionPage> createState() => _ClubSelectionPageState();
}

class _ClubSelectionPageState extends State<ClubSelectionPage> {
  late Future<List<ComputerClub>> _clubsFuture;

  @override
  void initState() {
    super.initState();
    _clubsFuture = KompovRepository.instance.getClubs();
  }

  Future<void> _selectClub(
    BuildContext context,
    ComputerClub club, {
    bool openDetails = false,
  }) async {
    currentClub = club;
    await KompovRepository.instance.loadClubCatalog(club.id);
    await KompovRepository.instance.refreshActiveSessions(
      currentClient.Id,
      club.id,
    );
    await KompovRepository.instance.refreshClientTransactions(currentClient.Id);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_club_id_${currentClient.id}', club.id);
    await prefs.setInt('selected_club_id', club.id);

    if (!context.mounted) return;
    Navigator.pushReplacementNamed(
      context,
      openDetails ? '/clubDetails' : '/home',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите клуб'),
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: FutureBuilder<List<ComputerClub>>(
        future: _clubsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Не удалось загрузить клубы.\nЗапустите API: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final clubs = snapshot.data ?? [];
          if (clubs.isEmpty) {
            return const Center(child: Text('Клубы не найдены в API'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              final club = clubs[index];
              final isSelected = club.id == currentClub.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.deepOrangeAccent
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _selectClub(context, club),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_city,
                                color: Colors.deepOrangeAccent),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                club.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  color: Colors.green),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(club.description),
                        const SizedBox(height: 12),
                        _ClubInfoLine(icon: Icons.place, text: club.address),
                        _ClubInfoLine(
                            icon: Icons.schedule, text: club.workTime),
                        if (club.phone.isNotEmpty)
                          _ClubInfoLine(icon: Icons.phone, text: club.phone),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              _selectClub(context, club, openDetails: true);
                            },
                            icon: const Icon(Icons.info_outline),
                            label: const Text('Подробнее'),
                          ),
                        ),
                      ],
                    ),
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

class _ClubInfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ClubInfoLine({required this.icon, required this.text});

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
