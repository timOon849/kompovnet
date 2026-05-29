import 'package:flutter/material.dart';
import 'package:kompovnet/data/client.dart';
import 'package:kompovnet/data/computer_club.dart';
import 'package:kompovnet/data/computer.dart';
import 'package:kompovnet/data/computer_status.dart';
import 'package:kompovnet/data/game_session.dart';
import 'package:kompovnet/data/game_zone.dart';
import 'package:kompovnet/data/promo_offer.dart';
import 'package:kompovnet/data/transaction.dart';

final List<Client> registeredClients = [
  Client(
    id: 1,
    firstName: 'Алексей',
    lastName: 'Ivanov',
    phoneNumber: '+7 (900) 123-45-67',
    login: '123',
    password: '123',
    balance: 1500.0,
  ),
  Client(
    id: 2,
    firstName: 'Дмитрий',
    lastName: 'Админов',
    phoneNumber: '+7 (900) 765-43-21',
    login: 'admin',
    password: 'qwe',
    balance: 5000.0,
  ),
  Client(
    id: 3,
    firstName: 'Максим',
    lastName: 'Козлов',
    phoneNumber: '+7 900 333-44-55',
    balance: 2400.0,
  ),
];

Client currentClient = registeredClients[0];

final List<ComputerClub> mockClubs = [
  ComputerClub(
    id: 1,
    name: 'KompovNet Центр',
    address: 'ул. Ленина, 10',
    phone: '+7 (900) 111-22-33',
    workTime: 'Круглосуточно',
    description: 'Главный клуб с VIP-залом, bootcamp-комнатой и ночными пакетами.',
  ),
  ComputerClub(
    id: 2,
    name: 'KompovNet Север',
    address: 'пр. Победы, 45',
    phone: '+7 (900) 444-55-66',
    workTime: '10:00 - 02:00',
    description: 'Уютный клуб рядом с университетом: стандартные места и отдельная VIP-зона.',
  ),
  ComputerClub(
    id: 3,
    name: 'KompovNet Арена',
    address: 'ул. Киберспорта, 7',
    phone: '+7 (900) 777-88-99',
    workTime: '12:00 - 06:00',
    description: 'Большой клуб для турниров, командных тренировок и просмотра матчей.',
  ),
];

ComputerClub currentClub = mockClubs[0];

/// Зоны, ПК и тарифы, загруженные из API для выбранного клуба.
List<GameZone> clubZones = [];
List<Computer> clubComputers = [];
List<PromoOffer> clubTariffs = [];

// --- 2. ИГРОВЫЕ ЗОНЫ ---
final List<GameZone> mockZones = [
  GameZone(
    id: 3,
    clubId: 1,
    name: 'Standard',
    description: 'Комфортные места, девайсы Logitech, мониторы 144Hz.',
    pricePerHour: 100.0,
    color: Colors.blue,
  ),
  GameZone(
    id: 1,
    clubId: 1,
    name: 'VIP',
    description: 'Приватные диваны, мощные ПК с RTX 4080, 240Hz.',
    pricePerHour: 250.0,
    color: Colors.amber,
  ),
  GameZone(
    id: 2,
    clubId: 1,
    name: 'Bootcamp',
    description: 'Для командных тренировок 5х5. Полная шумоизоляция.',
    pricePerHour: 200.0,
    color: Colors.deepPurple,
  ),
  GameZone(
    id: 4,
    clubId: 2,
    name: 'Standard',
    description: 'Базовая зона для повседневной игры и учебных перерывов.',
    pricePerHour: 90.0,
    color: Colors.blue,
  ),
  GameZone(
    id: 5,
    clubId: 2,
    name: 'VIP',
    description: 'Тихие места с усиленными ПК, креслами Cougar и мониторами 240Hz.',
    pricePerHour: 220.0,
    color: Colors.amber,
  ),
  GameZone(
    id: 6,
    clubId: 3,
    name: 'Arena',
    description: 'Турнирная зона с одинаковыми ПК и местами для команд 5х5.',
    pricePerHour: 180.0,
    color: Colors.redAccent,
  ),
  GameZone(
    id: 7,
    clubId: 3,
    name: 'Streaming',
    description: 'Места для стримов: камера, микрофон и отдельный свет.',
    pricePerHour: 300.0,
    color: Colors.purple,
  ),
];
final List<Computer> mockComputers = [
  // Standard (ID от 1 до 10, ZoneId: 3)
  for (int i = 1; i <= 10; i++)
    Computer(
      id: i,
      number: i,
      clubId: 1,
      zoneId: 3,
      status: i == 3 ? ComputerStatus.busy : ComputerStatus.free,
    ),

  // VIP (ID от 11 до 15, ZoneId: 1)
  for (int i = 11; i <= 15; i++)
    Computer(
      id: i,
      number: i,
      clubId: 1,
      zoneId: 1,
      status: ComputerStatus.free,
    ),

  // Bootcamp (ID от 21 до 30, ZoneId: 2)
  for (int i = 21; i <= 30; i++)
    Computer(
      id: i,
      number: i,
      clubId: 1,
      zoneId: 2,
      status: ComputerStatus.free,
    ),

  // KompovNet Север
  for (int i = 1; i <= 8; i++)
    Computer(
      id: 100 + i,
      number: i,
      clubId: 2,
      zoneId: 4,
      status: i == 2 ? ComputerStatus.busy : ComputerStatus.free,
    ),
  for (int i = 9; i <= 12; i++)
    Computer(
      id: 100 + i,
      number: i,
      clubId: 2,
      zoneId: 5,
      status: ComputerStatus.free,
    ),

  // KompovNet Арена
  for (int i = 1; i <= 10; i++)
    Computer(
      id: 200 + i,
      number: i,
      clubId: 3,
      zoneId: 6,
      status: ComputerStatus.free,
    ),
  for (int i = 11; i <= 14; i++)
    Computer(
      id: 200 + i,
      number: i,
      clubId: 3,
      zoneId: 7,
      status: i == 12 ? ComputerStatus.busy : ComputerStatus.free,
    ),
];

final List<PromoOffer> mockTariffs = [
  PromoOffer(
    id: 1,
    title: "Почасовой",
    description: "Обычная оплата по цене выбранной игровой зоны.",
    price: 0,
    durationHours: 1,
  ),
  PromoOffer(
    id: 2,
    title: "Пакет «3 часа»",
    description: "Удобный пакет для вечерней игры с друзьями.",
    price: 300,
    durationHours: 3,
    startHour: 10,
    endHour: 22,
  ),
  PromoOffer(
    id: 3,
    title: "Комбо «День»",
    description: "Действует в будни и дневное время. Подходит для долгой сессии.",
    price: 500,
    durationHours: 8,
    startHour: 9,
    endHour: 17,
  ),
  PromoOffer(
    id: 4,
    title: "Пакет «Ночь»",
    description: "Ночной тариф для длинной игровой сессии.",
    price: 600,
    durationHours: 10,
    startHour: 22,
    endHour: 8,
    isSpecial: true,
  ),
  PromoOffer(
    id: 5,
    title: "Arena Training",
    description: "Тариф для тренировок в клубе KompovNet Арена.",
    price: 700,
    durationHours: 4,
    clubId: 3,
    startHour: 12,
    endHour: 23,
  ),
];

// --- 4. ИСТОРИЯ СЕССИЙ ---
List<GameSession> activeSessions = [
  GameSession(
    id: 1,
    clientId: 1,
    clubId: 1,
    computerId: 2,
    startTime: DateTime(2026, 01, 15, 0, 30, 0),
    endTime: DateTime(2026, 01, 15, 6, 30, 1),
    totalCost: 100,
    status: BookingStatus.completed,
  )
];
List<Transaction> userTransactions = [
  Transaction(
    id: 1,
    clientId: currentClient.id,
    amount: 100,
    date: DateTime(2025, 12, 20),
    type: TransactionType.deposit,
    description: 'Пополнение баланса',
  ),
  Transaction(
    id: 2,
    clientId: currentClient.id,
    amount: 300,
    date: DateTime(2026, 02, 20),
    type: TransactionType.withdraw,
    description: 'Списание с баланса',
  ),
];
