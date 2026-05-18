import 'package:flutter/material.dart';
import 'package:kompovnet/data/game_session.dart';
import '../data/mock_data.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  void showSessionDecs(int id) {
    final currentSession = activeSessions.firstWhere((e) => e.id == id);

    final currentComputer = mockComputers.firstWhere(
      (s) => s.id == currentSession.computerId,
    );

    final currentZone = mockZones.firstWhere(
      (z) => z.id == currentComputer.zoneId,
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
              Text('Компьютер: №${currentComputer.number}'),
              const Divider(), // Визуальная черта
              Text('Дата: ${_formatDate(currentSession.startTime)}'),
              Text(
                'Начало: ${_formatTime(currentSession.startTime)}',
              ),
              Text(
                'Конец: ${_formatTime(currentSession.endTime)}',
              ),
              const SizedBox(height: 10),
              Text('Тариф: ${currentSession.tariffTitle}'),
              Text('Стоимость: ${currentSession.totalCost.toInt()} ₽'),
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

  void _cancelSession(GameSession session) {
    setState(() {
      session.status = BookingStatus.cancelled;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Бронь отменена')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Получаем только посещения текущего пользователя в выбранном клубе.
    final userHistory = activeSessions
        .where((s) => s.userId == currentUser.Id && s.clubId == currentClub.id)
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
      body: userHistory.isEmpty
          ? const Center(child: Text("В этом клубе у вас пока нет посещений"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: userHistory.length,
              itemBuilder: (context, index) {
                // Свежие посещения будут сверху
                final session = userHistory.reversed.toList()[index];
                final computer = mockComputers.firstWhere((pc) => pc.id == session.computerId);
                final zone = mockZones.firstWhere((z) => z.id == computer.zoneId);
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
                      "${_formatDate(session.startTime)} ${_formatTime(session.startTime)}",
                    ),
                    subtitle: Text(
                      "${zone.name}, ПК №${computer.number} • ${session.tariffTitle} • ${_statusText(status)}",
                    ),
                    trailing: session.canCancel
                        ? TextButton(
                            onPressed: () => _cancelSession(session),
                            child: const Text('Отмена'),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: () {
                      showSessionDecs(session.id);
                    },
                  ),
                );
              },
            ),
    );
  }

  BookingStatus _getSessionStatus(GameSession session) {
    if (session.status == BookingStatus.cancelled) {
      return BookingStatus.cancelled;
    }
    if (DateTime.now().isAfter(session.endTime)) {
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
