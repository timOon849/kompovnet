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

  static TransactionType fromName(String name) {
    return switch (name) {
      'BalanceTopUp' => BalanceTopUp,
      'BonusAccrual' => BonusAccrual,
      'SessionStart' => SessionStart,
      'SessionExtension' => SessionExtension,
      _ => BalanceTopUp,
    };
  }
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

  bool get isWithdraw =>
      Type == TransactionType.withdraw ||
      Type == TransactionType.SessionStart ||
      Type == TransactionType.SessionExtension;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final typeValue = json['type'] ?? json['Type'];
    final typeName = _parseEnumName(typeValue, const [
      'BalanceTopUp',
      'BonusAccrual',
      'SessionStart',
      'SessionExtension',
    ]);

    return Transaction(
      Id: (json['id'] ?? json['Id']) as int? ?? 0,
      ClubId: (json['clubId'] ?? json['ClubId']) as int? ?? 0,
      CashierShiftId: (json['cashierShiftId'] ?? json['CashierShiftId']) as int?,
      ClientId: (json['clientId'] ?? json['ClientId']) as int?,
      GameSessionId: (json['gameSessionId'] ?? json['GameSessionId']) as int?,
      PaymentTypeId: (json['paymentTypeId'] ?? json['PaymentTypeId']) as int? ?? 0,
      Amount: ((json['amount'] ?? json['Amount']) as num?)?.toDouble() ?? 0,
      Type: TransactionType.fromName(typeName),
      Description: _transactionDescription(typeName),
      Status: _parseEnumName(
        json['status'] ?? json['Status'],
        const ['Pending', 'Paid', 'Refunded', 'Cancelled'],
      ),
      CreatedAt: (json['createdAt'] ?? json['CreatedAt']) != null
          ? DateTime.parse((json['createdAt'] ?? json['CreatedAt']) as String)
          : DateTime.now(),
    );
  }

  static String _parseEnumName(dynamic value, List<String> names) {
    if (value is String) {
      return value;
    }
    if (value is int && value >= 0 && value < names.length) {
      return names[value];
    }
    return names.first;
  }

  static String _transactionDescription(String type) {
    return switch (type) {
      'BalanceTopUp' => 'Пополнение баланса',
      'BonusAccrual' => 'Бонусное пополнение',
      'SessionStart' => 'Старт сессии',
      'SessionExtension' => 'Продление сессии',
      _ => type,
    };
  }
}
