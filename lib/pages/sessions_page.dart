import 'package:flutter/material.dart';
import 'package:kompovnet/data/computer.dart';
import 'package:kompovnet/data/game_session.dart';
import 'package:kompovnet/data/game_zone.dart';
import '../data/mock_data.dart';
import 'package:kompovnet/services/kompov_repository.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  bool _isLoading = true;

  List<Computer> get _computers => clubComputers;

  List<GameZone> get _zones => clubZones;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _isLoading = true);
    try {
      if (clubZones.isEmpty) {
        await KompovRepository.instance.loadClubCatalog(currentClub.id);
      }
      await KompovRepository.instance.refreshActiveSessions(
        currentClient.Id,
        currentClub.id,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void showSessionDecs(int id) {
    final currentSession = activeSessions.firstWhere((e) => e.Id == id);

    final currentComputer = _computers.firstWhere(
      (s) => s.Id == currentSession.ComputerId,
    );

    final currentZone = _zones.firstWhere(
      (z) => z.id == currentComputer.ZoneId,
    );

    final currentSessionStatus = _getSessionStatus(currentSession);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Детали брони'),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Чтобы окно не было на весь экран
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Клуб: ${currentClub.name}'),
              Text(
                'Зона: ${currentZone.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Компьютер: №${currentComputer.Number}'),
              const Divider(), // Визуальная черта
              Text('Дата: ${_formatDate(currentSession.StartedAt)}'),
              Text(
                'Начало: ${_formatTime(currentSession.StartedAt)}',
              ),
              Text(
                'Конец: ${_formatTime(currentSession.PlannedEndAt)}',
              ),
              const SizedBox(height: 10),
              Text('Тариф: ${currentSession.tariffTitle}'),
              Text('Стоимость: ${currentSession.TotalPrice.toInt()} ₽'),
              Text('Статус: ${_statusText(currentSessionStatus)}'),
            ],
          ),
          actions: [
            if (currentSession.canCancel)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _cancelSession(currentSession);
                },
                child: const Text('Отменить бронь'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Понятно'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelSession(GameSession session) async {
    try {
      await KompovRepository.instance.cancelBooking(session.Id);
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Бронь отменена')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка отмены: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Получаем только посещения текущего пользователя в выбранном клубе.
    final userHistory = activeSessions
        .where((s) =>
            s.ClientId == currentClient.Id && s.ClubId == currentClub.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('История: ${currentClub.name}'),
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_sharp),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : userHistory.isEmpty
          ? const Center(child: Text("В этом клубе у вас пока нет посещений"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: userHistory.length,
              itemBuilder: (context, index) {
                // Свежие посещения будут сверху
                final session = userHistory.reversed.toList()[index];
                final computer = _computers.firstWhere((pc) => pc.Id == session.ComputerId);
                final zone = _zones.firstWhere((z) => z.id == computer.ZoneId);
                final status = _getSessionStatus(session);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: _statusColor(status), width: 4),
                    ),
                    color: Colors.white,
                  ),
                  child: ListTile(
                    title: Text(
                      "${_formatDate(session.StartedAt)} ${_formatTime(session.StartedAt)}",
                    ),
                    subtitle: Text(
                      "${zone.name}, ПК №${computer.Number} • ${session.tariffTitle} • ${_statusText(status)}",
                    ),
                    trailing: session.canCancel
                        ? TextButton(
                            onPressed: () => _cancelSession(session),
                            child: const Text('Отмена'),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: () {
                      showSessionDecs(session.Id);
                    },
                  ),
                );
              },
            ),
    );
  }

  BookingStatus _getSessionStatus(GameSession session) {
    if (session.Status == BookingStatus.cancelled) {
      return BookingStatus.cancelled;
    }
    if (DateTime.now().isAfter(session.PlannedEndAt)) {
      return BookingStatus.completed;
    }
    return BookingStatus.booked;
  }

  String _statusText(BookingStatus status) {
    if (status == BookingStatus.cancelled) return 'Отменена';
    if (status == BookingStatus.completed) return 'Завершена';
    return 'Забронирована';
  }

  Color _statusColor(BookingStatus status) {
    if (status == BookingStatus.cancelled) return Colors.grey;
    if (status == BookingStatus.completed) return Colors.green;
    return Colors.deepOrangeAccent;
  }

  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}";
  }

  String _formatTime(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
