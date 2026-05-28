class BookingStatus {
  final String Value;
  const BookingStatus._(this.Value);

  static const BookingStatus Created = BookingStatus._('Created');
  static const BookingStatus Active = BookingStatus._('Active');
  static const BookingStatus Completed = BookingStatus._('Completed');
  static const BookingStatus Cancelled = BookingStatus._('Cancelled');
  static const BookingStatus NoShow = BookingStatus._('NoShow');

  // Backward compatibility for current UI
  static const BookingStatus booked = Created;
  static const BookingStatus completed = Completed;
  static const BookingStatus cancelled = Cancelled;
}

class GameSession {
  int Id;
  int ClubId;
  int ComputerId;
  int ClientId;
  int CashierShiftId;
  int TariffId;
  int TariffZoneId;
  DateTime StartedAt;
  DateTime PlannedEndAt;
  DateTime? EndedAt;
  double InitialPrice;
  double TotalPrice;
  BookingStatus Status;

  GameSession({
    int? id,
    int? clientId,
    int? clubId,
    int? computerId,
    this.Id = 0,
    this.ClientId = 0,
    this.ClubId = 0,
    this.ComputerId = 0,
    DateTime? startTime,
    DateTime? endTime,
    double? totalCost,
    double? priceAtBooking,
    this.CashierShiftId = 0,
    this.TariffId = 0,
    this.TariffZoneId = 0,
    DateTime? StartedAt,
    DateTime? PlannedEndAt,
    this.EndedAt,
    double? InitialPrice,
    double? TotalPrice,
    BookingStatus? status,
    String? tariffTitle,
  })  : StartedAt = StartedAt ?? startTime ?? DateTime.now(),
        PlannedEndAt =
            PlannedEndAt ?? endTime ?? DateTime.now().add(const Duration(hours: 1)),
        InitialPrice = InitialPrice ?? priceAtBooking ?? totalCost ?? 0,
        TotalPrice = TotalPrice ?? totalCost ?? 0,
        Status = status ?? BookingStatus.booked {
    if (id != null) Id = id;
    if (clientId != null) ClientId = clientId;
    if (clubId != null) ClubId = clubId;
    if (computerId != null) ComputerId = computerId;
  }

  // Compatibility for existing UI code
  int get id => Id;
  int get clientId => ClientId;
  int get clubId => ClubId;
  int get computerId => ComputerId;
  DateTime get startTime => StartedAt;
  DateTime get endTime => PlannedEndAt;
  double get totalCost => TotalPrice;
  double get priceAtBooking => InitialPrice;
  String get tariffTitle => 'Почасовой';
  BookingStatus get status => Status;
  set status(BookingStatus value) => Status = value;

  bool get isActive => DateTime.now().isBefore(PlannedEndAt);
  bool get canCancel =>
      Status == BookingStatus.booked && DateTime.now().isBefore(StartedAt);
}
