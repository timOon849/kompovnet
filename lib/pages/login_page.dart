import 'package:flutter/material.dart';
import 'package:kompovnet/data/mock_data.dart';
import 'package:kompovnet/services/kompov_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isBusy = false;

  void _showRegisterDialog() {
    // Контроллеры для полей регистрации
    final TextEditingController regLoginController = TextEditingController();
    final TextEditingController regPassController = TextEditingController();
    final TextEditingController regNameController = TextEditingController();
    final TextEditingController regLastNameController = TextEditingController();
    final TextEditingController regPhoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Регистрация"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: regNameController,
                  decoration: const InputDecoration(labelText: "Ваше имя"),
                ),
                TextField(
                  controller: regLastNameController,
                  decoration: const InputDecoration(labelText: "Ваша фамилия"),
                ),
                TextField(
                  controller: regPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: "Телефон"),
                ),
                TextField(
                  controller: regLoginController,
                  decoration: const InputDecoration(labelText: "Придумайте логин"),
                ),
                TextField(
                  controller: regPassController,
                  decoration: const InputDecoration(labelText: "Пароль"),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Закрыть окно
              child: const Text("Отмена"),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = regNameController.text.trim();
                final lastName = regLastNameController.text.trim();
                final phone = regPhoneController.text.trim();
                final login = regLoginController.text.trim();
                final password = regPassController.text.trim();

                if (name.isEmpty ||
                    lastName.isEmpty ||
                    phone.isEmpty ||
                    login.isEmpty ||
                    password.isEmpty) {
                  _showMessage("Заполните все поля регистрации");
                  return;
                }

                if (password.length < 3) {
                  _showMessage("Пароль должен быть не короче 3 символов");
                  return;
                }

                try {
                  final createdClient = await KompovRepository.instance.register(
                    firstName: name,
                    lastName: lastName,
                    phone: phone,
                    login: login,
                    password: password,
                  );
                  if (!context.mounted) return;
                  currentClient = createdClient;
                  Navigator.pop(context);
                  _showMessage("Регистрация успешна! Выберите клуб.");
                  Navigator.pushReplacementNamed(context, '/clubs');
                } catch (e) {
                  _showMessage(e.toString().replaceFirst('Exception: ', ''));
                }
              },
              child: const Text("Создать"),
            ),
          ],
        );
      },
    );
  }


  // Контроллеры позволяют забирать текст из полей ввода
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final inputLogin = _loginController.text.trim();
    final inputPass = _passwordController.text.trim();

    if (inputLogin.isEmpty || inputPass.isEmpty) {
      _showMessage("Введите логин/телефон и пароль");
      return;
    }

    setState(() => _isBusy = true);
    try {
      final foundMember =
          await KompovRepository.instance.login(inputLogin, inputPass);
      if (foundMember == null) {
        _showMessage("Неверный логин или пароль!");
        return;
      }

      currentClient = foundMember;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('saved_user_id', foundMember.Id);
      await prefs.setBool('is_logged_in', true);
      final int? boundClubId =
          prefs.getInt('selected_club_id_${foundMember.Id}') ??
          prefs.getInt('selected_club_id');

      if (boundClubId != null) {
        final clubs = await KompovRepository.instance.getClubs();
        currentClub = clubs.firstWhere((club) => club.id == boundClubId);
        await KompovRepository.instance.loadClubCatalog(boundClubId);
        await KompovRepository.instance.refreshActiveSessions(
          foundMember.Id,
          boundClubId,
        );
        await KompovRepository.instance.refreshClientTransactions(foundMember.Id);
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        boundClubId == null ? '/clubs' : '/home',
        arguments: foundMember,
      );
    } catch (e) {
      _showMessage("Не удалось подключиться к API. Запустите KompovNetApi.");
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: SingleChildScrollView( // Чтобы клавиатура не закрывала контент
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Логотип или иконка клуба
                Image.asset('assets/images/logo.png', width: 180),
                const SizedBox(height: 20),
                const Text(
                  "Вход в приложение",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Используйте логин или телефон",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 35),

                // Поле Логина
                TextField(
                  controller: _loginController,
                  decoration: InputDecoration(
                    labelText: 'Логин или Телефон',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),

                // Поле Пароля
                TextField(
                  controller: _passwordController,
                  obscureText: true, // Скрывает символы (для пароля)
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 30),

                // Кнопка Входа
                SizedBox(
                  width: double.infinity, // Кнопка на всю ширину
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isBusy ? null : _login,
                    child: Text(
                      _isBusy ? "ВХОД..." : "ВОЙТИ",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),

                TextButton(
                  onPressed: (){
                    _showRegisterDialog();
                  },
                  child: Text("Нет аккаунта? Зарегистрироваться", style: TextStyle(color: Colors.grey[700])),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
