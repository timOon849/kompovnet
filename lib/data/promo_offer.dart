class PromoOffer {
  final int id;
  final int? clubId;
  final String title; // Название (напр., "Пакет Ночной")
  final String description; // Описание условий
  final double price; // Стоимость в рублях
  final int durationHours; // Длительность в часах
  final int? startHour; // Час начала действия тарифа
  final int? endHour; // Час окончания действия тарифа
  final bool isSpecial; // Выделять ли карту визуально (акция)
  final bool isForBooking;

  PromoOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.durationHours,
    this.clubId,
    this.startHour,
    this.endHour,
    this.isSpecial = false,
    this.isForBooking = true,
  });

  String get duration => "$durationHours ч.";

  String get timeText {
    if (startHour == null || endHour == null) return "В любое время";
    return "С ${_formatHour(startHour!)} до ${_formatHour(endHour!)}";
  }

  bool isAvailableAt(DateTime startTime) {
    if (startHour == null || endHour == null) return true;

    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endTime = startTime.add(Duration(hours: durationHours));
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final tariffStart = startHour! * 60;
    final tariffEnd = endHour! * 60;

    if (tariffStart < tariffEnd) {
      return startMinutes >= tariffStart &&
          endMinutes <= tariffEnd &&
          startTime.day == endTime.day;
    }

    return startMinutes >= tariffStart && endMinutes <= tariffEnd;
  }

  String _formatHour(int hour) {
    return "${hour.toString().padLeft(2, '0')}:00";
  }
}
