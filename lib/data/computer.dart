enum ComputerStatus { free, busy, maintenance }

class Computer {
  final int id;
  final int number;
  final int clubId;
  final int zoneId;
  ComputerStatus status;

  Computer({
    required this.id,
    required this.number,
    required this.clubId,
    required this.zoneId,
    this.status = ComputerStatus.free,
  });
}
