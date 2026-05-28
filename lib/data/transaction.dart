class TransactionType {
  final String Value;
  const TransactionType._(this.Value);
  static const TransactionType BalanceTopUp = TransactionType._('BalanceTopUp');
  static const TransactionType BonusAccrual = TransactionType._('BonusAccrual');
  static const TransactionType SessionStart = TransactionType._('SessionStart');
  static const TransactionType SessionExtension =
      TransactionType._('SessionExtension');
  static const TransactionType deposit = BalanceTopUp;
  static const TransactionType withdraw = SessionStart;
}

class PaymentStatus {
  static const String Pending = 'Pending';
  static const String Paid = 'Paid';
  static const String Refunded = 'Refunded';
  static const String Cancelled = 'Cancelled';
}

class Transaction {
  int Id;
  int ClubId;
  int? CashierShiftId;
  int? ClientId;
  int? GameSessionId;
  int PaymentTypeId;
  double Amount;
  TransactionType Type;
  String Description;
  int? ComputerId;
  String ComputerName;
  String Status;
  DateTime CreatedAt;

  Transaction({
    this.Id = 0,
    this.ClubId = 0,
    this.CashierShiftId,
    this.ClientId,
    this.GameSessionId,
    this.PaymentTypeId = 0,
    this.Amount = 0,
    this.Type = TransactionType.BalanceTopUp,
    this.Description = '',
    this.ComputerId,
    this.ComputerName = '',
    this.Status = PaymentStatus.Pending,
    DateTime? CreatedAt,
    int? id,
    int? clientId,
    double? amount,
    DateTime? date,
    TransactionType? type,
    String? description,
  }) : CreatedAt = CreatedAt ?? date ?? DateTime.now() {
    if (id != null) Id = id;
    if (clientId != null) ClientId = clientId;
    if (amount != null) Amount = amount;
    if (type != null) Type = type;
    if (description != null) Description = description;
  }

  // Compatibility for current UI code
  int get id => Id;
  int get clientId => ClientId ?? 0;
  double get amount => Amount;
  DateTime get date => CreatedAt;
  TransactionType get type => Type;
  String get description => Description;

  bool get isWithdraw => Type == TransactionType.withdraw;
}
