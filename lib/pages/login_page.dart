import 'package:flutter/material.dart';
import 'package:kompovnet/data/mock_data.dart';
import 'package:kompovnet/data/client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
              onPressed: () {
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

                final loginExists = registeredClients.any(
                  (member) =>
                      member.login?.toLowerCase() == login.toLowerCase(),
                );
                if (loginExists) {
                  _showMessage("Такой логин уже занят");
                  return;
                }

                final phoneExists = registeredClients.any(
                  (member) => member.phoneNumber == phone,
                );
                if (phoneExists) {
                  _showMessage("Такой телефон уже указан у другого пользователя");
                  return;
                }

                final newId = registeredClients.isEmpty
                    ? 1
                    : registeredClients
                            .map((member) => member.Id)
                            .reduce((a, b) => a > b ? a : b) +
                        1;

                setState(() {
                  registeredClients.add(Client(
                    Id: newId,
                    FirstName: name,
                    LastName: lastName,
                    PhoneNumber: phone,
                    Login: login,
                    Password: password,
                  ));
                });
                Navigator.pop(context); // Закрываем окно после сохранения
                _showMessage("Регистрация успешна! Теперь войдите.");
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

    try {
      final foundMember = registeredClients.firstWhere(
        (member) =>
            (member.login?.toLowerCase() == inputLogin.toLowerCase() ||
                member.phoneNumber == inputLogin) &&
            member.password == inputPass,
      );

      currentClient = foundMember;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('saved_user_id', foundMember.Id);
      await prefs.setBool('is_logged_in', true);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/clubs', arguments: foundMember);
    } catch (e) {
      _showMessage("Неверный логин или пароль!");
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
                    onPressed: _login,
                    child: const Text(
                      "ВОЙТИ",
                      style: TextStyle(color: Colors.white, fontSize: 16),
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
