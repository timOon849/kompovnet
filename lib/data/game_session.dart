enum BookingStatus { booked, completed, cancelled }

class GameSession {
  final int id;
  final int userId;
  final int clubId;
  final int computerId;
  final DateTime createdAt;
  final DateTime startTime;
  final DateTime endTime;
  final double totalCost;
  final double priceAtBooking;
  final String tariffTitle;
  BookingStatus status;

  GameSession({
    required this.id,
    required this.userId,
    required this.clubId,
    required this.computerId,
    DateTime? createdAt,
    required this.startTime,
    required this.endTime,
    required this.totalCost,
    double? priceAtBooking,
    this.tariffTitle = 'Почасовой',
    this.status = BookingStatus.booked,
  })  : createdAt = createdAt ?? DateTime.now(),
        priceAtBooking = priceAtBooking ?? totalCost;

  bool get isActive => DateTime.now().isBefore(endTime);
  bool get canCancel =>
      status == BookingStatus.booked && DateTime.now().isBefore(startTime);
}
