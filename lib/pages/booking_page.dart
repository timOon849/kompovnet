import 'package:flutter/material.dart';
import 'package:kompovnet/data/computer.dart';
import 'package:kompovnet/data/computer_status.dart';
import 'package:kompovnet/data/game_session.dart';
import 'package:kompovnet/data/game_zone.dart';
import 'package:kompovnet/data/promo_offer.dart';
import '../data/mock_data.dart';
import 'package:kompovnet/services/kompov_repository.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  bool _isSubmitting = false;
  bool _isLoading = true;
  int selectedZoneIndex = 0;
  int? selectedComputerId;
  int selectedHours = 1;
  PromoOffer? selectedTariff;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    try {
      if (clubZones.isEmpty || clubTariffs.isEmpty) {
        await KompovRepository.instance.loadClubCatalog(currentClub.id);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Бронирование ПК"),
          backgroundColor: Colors.deepOrangeAccent,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final clubZonesList = clubZones
        .where((zone) => zone.clubId == currentClub.id)
        .toList();

    if (clubZonesList.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Бронирование ПК"),
          centerTitle: true,
          backgroundColor: Colors.deepOrangeAccent,
        ),
        body: const Center(child: Text("В выбранном клубе пока нет игровых зон")),
      );
    }

    final currentZone = clubZonesList[selectedZoneIndex];
    final int currentZoneId = currentZone.id;

    final List<Computer> computersToShow = clubComputers
        .where((pc) => pc.ClubId == currentClub.id && pc.ZoneId == currentZoneId)
        .toList();

    final DateTime startTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    final bookingTariffs =
        clubTariffs.where((tariff) => tariff.isForBooking).toList();
    final DateTime endTime = startTime.add(Duration(hours: selectedHours));
    final double totalCost = selectedTariff == null || selectedTariff!.price == 0
        ? selectedHours * currentZone.pricePerHour
        : selectedTariff!.price;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Бронирование ПК"),
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Клуб: ${currentClub.name}\nВыберите игровую зону:",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: clubZonesList.length,
                itemBuilder: (context, index) {
                  bool isSelected = selectedZoneIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() {
                      selectedZoneIndex = index;
                      selectedComputerId = null;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.deepOrangeAccent : Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          clubZonesList[index].name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                currentZone.description,
                style: const TextStyle(color: Colors.grey),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.calendar_month),
                        title: const Text("Дата"),
                        subtitle: Text(_formatDate(selectedDate)),
                        onTap: _selectDate,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: const Text("Время начала"),
                        subtitle: Text(_formatTime(selectedTime)),
                        onTap: _selectTime,
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Expanded(child: Text("Длительность")),
                            IconButton(
                              color: Colors.red,
                              onPressed: () => setState(() {
                                if (selectedHours > 1) selectedHours--;
                                selectedTariff = null;
                              }),
                              icon: const Icon(Icons.remove_circle_sharp),
                            ),
                            Text(
                              "$selectedHours ч.",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              color: Colors.green,
                              onPressed: () => setState(() {
                                selectedHours++;
                                selectedTariff = null;
                              }),
                              icon: const Icon(Icons.add_circle_sharp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Выберите тариф:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 170,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16),
                itemCount: bookingTariffs.length,
                itemBuilder: (context, index) {
                  final tariff = bookingTariffs[index];
                  final isSelected = selectedTariff?.id == tariff.id;
                  final isAvailable = tariff.isAvailableAt(startTime);
                  final tariffPrice = tariff.price == 0
                      ? tariff.durationHours * currentZone.pricePerHour
                      : tariff.price;

                  return GestureDetector(
                    onTap: isAvailable
                        ? () => setState(() {
                              selectedTariff = tariff;
                              selectedHours = tariff.durationHours;
                              selectedComputerId = null;
                            })
                        : null,
                    child: Container(
                      width: 220,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.deepOrangeAccent
                            : (isAvailable ? Colors.white : Colors.grey[200]),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? Colors.deepOrangeAccent : Colors.black12,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 6),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  tariff.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              if (tariff.isSpecial)
                                const Icon(Icons.star, color: Colors.amber, size: 20),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tariff.timeText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected ? Colors.white70 : Colors.grey[700],
                            ),
                          ),
                          Text(
                            "${tariff.durationHours} ч. • ${tariffPrice.toInt()} ₽",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.deepOrangeAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!isAvailable)
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Text(
                                "Недоступен в это время",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Свободные места на выбранное время:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: computersToShow.length,
              itemBuilder: (context, index) {
                final pc = computersToShow[index];
                bool isSelected = selectedComputerId == pc.Id;
                bool isBusy =
                    pc.Status == ComputerStatus.busy ||
                    _hasBookingConflict(pc.Id, startTime, endTime);

                return InkWell(
                  onTap: isBusy
                      ? null
                      : () => setState(() => selectedComputerId = pc.Id),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isBusy
                          ? Colors.grey[400]
                          : (isSelected
                                ? Colors.green
                                : Colors.deepOrangeAccent.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected ? Border.all(color: Colors.green, width: 2) : null,
                    ),
                    child: Center(
                      child: Text(
                        "${pc.Number}",
                        style: TextStyle(color: isBusy ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                );
              },
            ),

            if (selectedComputerId != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                    foregroundColor: Colors.white70,
                  ),
                  onPressed: () {
                    final selectedComputer = computersToShow.firstWhere(
                      (pc) => pc.Id == selectedComputerId,
                    );
                    _showConfirmBooking(
                      currentZone,
                      selectedComputer,
                      startTime,
                      endTime,
                      totalCost,
                      selectedTariff,
                    );
                  },
                  child: Text("Подтвердить бронь на ${selectedHours} ч."),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date == null) return;
    if (!mounted) return;

    setState(() {
      selectedDate = date;
      selectedComputerId = null;
      selectedTariff = null;
    });
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (time == null) return;
    if (!mounted) return;

    setState(() {
      selectedTime = time;
      selectedComputerId = null;
      selectedTariff = null;
    });
  }

  bool _hasBookingConflict(int computerId, DateTime start, DateTime end) {
    return activeSessions.any((session) {
      if (session.ComputerId != computerId) return false;
      if (session.Status != BookingStatus.booked) return false;

      final startsBeforeExistingEnds = start.isBefore(session.PlannedEndAt);
      final endsAfterExistingStarts = end.isAfter(session.StartedAt);
      return startsBeforeExistingEnds && endsAfterExistingStarts;
    });
  }

  Future<void> _showConfirmBooking(
    GameZone zone,
    Computer computer,
    DateTime start,
    DateTime end,
    double cost,
    PromoOffer? tariff,
  ) async {
    if (start.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Нельзя забронировать прошедшее время")),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Подтверждение брони"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Клуб: ${currentClub.name}"),
              Text("Зона: ${zone.name}"),
              Text("ПК: №${computer.Number}"),
              const Divider(),
              Text("Дата: ${_formatDate(start)}"),
              Text("Время: ${_formatTimeOfDate(start)} - ${_formatTimeOfDate(end)}"),
              Text("Тариф: ${tariff?.title ?? 'Почасовой'}"),
              Text("Стоимость: ${cost.toInt()} ₽"),
              const SizedBox(height: 8),
              const Text("Оплата сейчас не списывается с баланса."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Отмена"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Забронировать"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    if (!mounted) return;

    _confirmBooking(zone, computer, start, end, cost, tariff);
  }

  Future<void> _confirmBooking(
    GameZone zone,
    Computer computer,
    DateTime start,
    DateTime end,
    double cost,
    PromoOffer? tariff,
  ) async {
    setState(() => _isSubmitting = true);
    try {
      await KompovRepository.instance.createBooking(
        clubId: currentClub.id,
        clientId: currentClient.Id,
        computerId: computer.Id,
        zoneId: zone.id,
        startsAt: start,
        endsAt: end,
      );
      await KompovRepository.instance.refreshActiveSessions(
        currentClient.Id,
        currentClub.id,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/sessions');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Успешно забронировано: ПК №${computer.Number}, ${zone.name}",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка бронирования: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}";
  }

  String _formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  String _formatTimeOfDate(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

}
