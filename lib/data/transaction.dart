enum TransactionType { deposit, withdraw }

class Transaction {
  final int id;
  final int userId;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String description;

  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.date,
    required this.type,
    required this.description,
  });
}
