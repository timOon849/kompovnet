import 'package:flutter/material.dart';
import 'package:kompovnet/data/mock_data.dart';
import 'package:kompovnet/services/kompov_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _refreshFromApi();
  }

  Future<void> _refreshFromApi() async {
    try {
      await KompovRepository.instance.refreshCurrentClient();
      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      // API недоступен — показываем последние локальные данные
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = currentClient;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        centerTitle: true,
        title: Image.asset('assets/images/logo.png', width: 150, height: 150),
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepOrangeAccent),
              padding: const EdgeInsets.only(bottom: 30),
              child: Image.asset('assets/images/logo.png', height: 150, width: 150),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Профиль"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile', arguments: client);
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_attraction_rounded),
              title: const Text("Акции и предложения"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/promotions');
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city),
              title: const Text("Сменить клуб"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/clubs');
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Выход"),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('saved_user_id');
                await prefs.setBool('is_logged_in', false);

                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFromApi,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepOrangeAccent, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.orange,
                      blurRadius: 20,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ваш баланс",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${client.balance.toInt()} ₽',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Клуб: ${currentClub.name}",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Быстрые действия",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ActionButton(
                        icon: Icons.computer,
                        label: "Забронировать ПК",
                        onTap: () => Navigator.pushNamed(context, '/booking'),
                      ),
                      _ActionButton(
                        icon: Icons.history,
                        label: "Мои брони",
                        onTap: () => Navigator.pushNamed(context, '/sessions'),
                      ),
                      _ActionButton(
                        icon: Icons.receipt_long,
                        label: "История операций",
                        onTap: () =>
                            Navigator.pushNamed(context, '/transactions'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepOrangeAccent),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
