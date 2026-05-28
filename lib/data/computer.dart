class ComputerStatus {
  static const String On = 'On';
  static const String Off = 'Off';
  static const String Reserved = 'Reserved';
  static const String SessionActive = 'SessionActive';
  static const String Maintenance = 'Maintenance';
  static const String free = On;
  static const String busy = SessionActive;
}

class Computer {
  int Id;
  int ClubId;
  String Number;
  String? Name;
  int ZoneId;
  int ComputerStatusId;
  String Status;
  String? Processor;
  String? GraphicsCard;
  int RamGb;
  String? Monitor;

  Computer({
    int? id,
    int? clubId,
    int? zoneId,
    int? computerStatusId,
    this.Id = 0,
    this.ClubId = 0,
    required int number,
    String? Name,
    this.ZoneId = 0,
    int? ComputerStatusId,
    String? status,
    this.Processor,
    this.GraphicsCard,
    this.RamGb = 16,
    this.Monitor,
  })  : Number = number.toString(),
        Name = Name ?? 'PC $number',
        ComputerStatusId = ComputerStatusId ?? 0,
        Status = status ?? ComputerStatus.free {
    if (id != null) Id = id;
    if (clubId != null) ClubId = clubId;
    if (zoneId != null) ZoneId = zoneId;
    if (computerStatusId != null) ComputerStatusId = computerStatusId;
  }

  // Compatibility for existing code
  int get id => Id;
  int get clubId => ClubId;
  int get number => int.tryParse(Number) ?? 0;
  int get zoneId => ZoneId;
  String get status => Status;
}
