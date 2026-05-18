import 'package:flutter/material.dart';
import 'package:kompovnet/data/mock_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = currentUser;

    return Scaffold(
      // 1. ВЕРХНЯЯ ПАНЕЛЬ (теперь она будет отображаться корректно)
      appBar: AppBar(
        toolbarHeight: 90,
        centerTitle: true,
        title: Image.asset('assets/images/logo.png', width: 150, height: 150),
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 0, // Убираем тень для чистого вида
      ),

      // 2. БОКОВОЕ МЕНЮ (Drawer)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepOrangeAccent),
              child: Image.asset('assets/images/logo.png', height: 150, width: 150),
              padding: EdgeInsets.only(bottom: 30),
            ),
            ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Профиль"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile', arguments: user);
                }),
            ListTile(
                leading: const Icon(Icons.local_attraction_rounded),
                title: const Text("Акции и предложения"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/promotions');
                }
            ),
            ListTile(
                leading: const Icon(Icons.location_city),
                title: const Text("Сменить клуб"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/clubs');
                }),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Выход"),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('saved_user_id');
                await prefs.remove('selected_club_id');
                await prefs.setBool('is_logged_in', false);

                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
            ),
          ],
        ),
      ),

      // 3. ОСНОВНОЙ КОНТЕНТ
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // КАРТОЧКА БАЛАНСА
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepOrangeAccent, Colors.orange],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange,
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ваш баланс", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  SizedBox(height: 10),
                  Text(
                    '${user.balance.toInt()} ₽',
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Статус: Pro Player",
                    style: TextStyle(color: Colors.white, fontSize: 14),
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
                    Row(
                      children: [
                        const Icon(Icons.location_city, color: Colors.deepOrangeAccent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            currentClub.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(currentClub.address),
                    Text('Режим работы: ${currentClub.workTime}'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/clubDetails'),
                            icon: const Icon(Icons.info_outline),
                            label: const Text('Подробнее'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/clubs'),
                            icon: const Icon(Icons.swap_horiz),
                            label: const Text('Сменить'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              "Быстрый доступ",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            Column(
              children: [
                _buildMenuCard(context, Icons.computer, "Бронь ПК", Colors.blue, () {
                  Navigator.pushNamed(context, '/booking');
                }),
                const SizedBox(height: 12),
                _buildMenuCard(context, Icons.history_toggle_off, "Мои брони", Colors.purple, () {
                  Navigator.pushNamed(context, '/sessions');
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Вспомогательный метод для создания кнопок
  Widget _buildMenuCard(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}
