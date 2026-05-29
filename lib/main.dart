import 'package:flutter/material.dart';
import 'package:kompovnet/pages/club_details_page.dart';
import 'package:kompovnet/pages/club_selection_page.dart';
import 'package:kompovnet/pages/edit_profile_page.dart';
import 'package:kompovnet/pages/rates_page.dart';
import 'package:kompovnet/pages/sessions_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kompovnet/data/mock_data.dart';
import 'package:kompovnet/services/kompov_repository.dart';

// Твои импорты страниц
import 'package:kompovnet/pages/booking_page.dart';
import 'package:kompovnet/pages/home_page.dart';
import 'package:kompovnet/pages/login_page.dart';
import 'package:kompovnet/pages/profile_page.dart';
import 'package:kompovnet/pages/transactions_page.dart';

void main() async {
  // 1. Обязательная строчка для работы с асинхронностью в main
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Инициализируем хранилище
  final prefs = await SharedPreferences.getInstance();
  final int? savedId = prefs.getInt('saved_user_id');

  String initialRoute = '/'; // По умолчанию идем на логин

  // 3. Если ID найден, ищем пользователя в нашей "базе"
  if (savedId != null) {
    try {
      final client = await KompovRepository.instance.getClient(savedId);
      if (client != null) {
        currentClient = client;
        final int? savedClubId =
            prefs.getInt('selected_club_id_${currentClient.id}') ??
            prefs.getInt('selected_club_id');
        if (savedClubId != null) {
          final clubs = await KompovRepository.instance.getClubs();
          currentClub = clubs.firstWhere((club) => club.id == savedClubId);
          await KompovRepository.instance.loadClubCatalog(savedClubId);
          await KompovRepository.instance.refreshActiveSessions(
            currentClient.Id,
            savedClubId,
          );
          await KompovRepository.instance.refreshClientTransactions(
            currentClient.Id,
          );
          initialRoute = '/home';
        } else {
          initialRoute = '/clubs';
        }
      }
    } catch (e) {
      debugPrint("Не удалось восстановить сессию из API: $e");
    }
  }

  runApp(MyApp(startScreen: initialRoute));
}

class MyApp extends StatelessWidget {
  final String startScreen;
  const MyApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.deepOrangeAccent),

      // Используем начальный экран, который определили в main
      initialRoute: startScreen,

      routes: {
        '/': (context) => LoginPage(),
        '/clubs': (context) => const ClubSelectionPage(),
        '/clubDetails': (context) => const ClubDetailsPage(),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
        '/booking': (context) => BookingPage(),
        '/transactions': (context) => TransactionsPage(),
        '/sessions': (context) => SessionsPage(),
        '/editProfile': (context) => EditProfilePage(),
        '/promotions': (context) => RatesPage(),
      },
    );
  }
}
