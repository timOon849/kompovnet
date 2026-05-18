import 'package:flutter/material.dart';
import 'package:kompovnet/data/game_session.dart';
import 'package:kompovnet/data/mock_data.dart';
import 'package:kompovnet/data/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _showDepositBalance() {
    final TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Пополнение баланса'),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Введите сумму',
              suffixText: "₽",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Отмена'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                double amount = double.tryParse(amountController.text) ?? 0;

                if (amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Введите сумму больше 0')),
                  );
                  return;
                }

                setState(() {
                  currentUser.balance += amount;
                  userTransactions.add(
                    Transaction(
                      id: DateTime.now().millisecondsSinceEpoch,
                      userId: currentUser.Id,
                      amount: amount,
                      date: DateTime.now(),
                      type: TransactionType.deposit,
                      description: 'Пополнение баланса',
                    ),
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Баланс пополнен')),
                );
              },
              label: const Text('Пополнить'),
              icon: const Icon(Icons.attach_money_rounded),
            )
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_user_id');
    await prefs.remove('selected_club_id');
    await prefs.setBool('is_logged_in', false);

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final userSessions = activeSessions
        .where(
          (session) =>
              session.userId == currentUser.Id &&
              session.status != BookingStatus.cancelled,
        )
        .toList();
    final activeBookings = userSessions
        .where(
          (session) =>
              session.status == BookingStatus.booked &&
              DateTime.now().isBefore(session.endTime),
        )
        .length;
    final completedVisits = userSessions
        .where((session) => DateTime.now().isAfter(session.endTime))
        .length;
    final userInitials = _getInitials(currentUser.name, currentUser.lastName);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Убираем авто-стрелку
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ШАПКА С ИМЕНЕМ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Colors.deepOrangeAccent,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white,
                    child: Text(
                      userInitials,
                      style: const TextStyle(
                        color: Colors.deepOrangeAccent,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "${currentUser.name} ${currentUser.lastName}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Логин: ${currentUser.login}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  if (currentUser.phone.isNotEmpty)
                    Text(
                      "Телефон: ${currentUser.phone}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    "Клуб: ${currentClub.name}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            // БЛОК СТАТИСТИКИ
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem("$completedVisits", "Визитов"),
                    _buildStatItem("$activeBookings", "Броней"),
                    _buildStatItem("${currentUser.balance.toInt()} ₽", "Баланс"),
                  ],
                ),
              ),
            ),

            // МЕНЮ
            _buildProfileOption(Icons.history, "История транзакций", () {
              Navigator.pushNamed(context, '/transactions');
            }),
            _buildProfileOption(Icons.account_balance_wallet, "Пополнить баланс", () {
              _showDepositBalance();
            }),
            _buildProfileOption(Icons.history_toggle_off_sharp, "История посещений", () {
              Navigator.pushNamed(context, '/sessions');
            }),
            _buildProfileOption(Icons.settings, "Настройки аккаунта", () async {
              final wasSaved = await Navigator.pushNamed(context, '/editProfile');
              if (wasSaved == true) {
                setState(() {});
              }
            }),

            const SizedBox(height: 30),

            // КНОПКА ВЫХОДА
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextButton(
                onPressed: _logout,
                child: const Text("Выйти из системы", style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name, String lastName) {
    final first = name.isNotEmpty ? name[0] : '';
    final second = lastName.isNotEmpty ? lastName[0] : '';
    return "$first$second".toUpperCase();
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrangeAccent,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepOrangeAccent),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }
}
