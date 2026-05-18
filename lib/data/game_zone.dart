import 'package:flutter/material.dart';

class GameZone {
  final int id;
  final int clubId;
  final String name;
  final String description;
  final double pricePerHour;
  final Color color;

  GameZone({
    required this.id,
    required this.clubId,
    required this.name,
    required this.description,
    required this.pricePerHour,
    required this.color,
  });
}
