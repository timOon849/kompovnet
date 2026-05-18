import 'package:flutter/material.dart';
import 'package:kompovnet/data/mock_data.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = currentUser.name;
    _lastnameController.text = currentUser.lastName;
    _phoneController.text = currentUser.phone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    final lastName = _lastnameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните имя и фамилию')),
      );
      return;
    }

    final updatedUser = currentUser.copyWith(
      name: name,
      lastName: lastName,
      phone: phone,
    );

    final userIndex = registeredUsers.indexWhere((user) => user.Id == currentUser.Id);
    if (userIndex != -1) {
      registeredUsers[userIndex] = updatedUser;
    }

    currentUser = updatedUser;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Изменения успешно сохранены')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование профиля'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close_sharp),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Имя',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lastnameController,
              decoration: const InputDecoration(
                labelText: 'Фамилия',
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Телефон',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 40),
              ),
              onPressed: _saveProfile,
              child: const Text('Сохранить изменения'),
            )
          ],
        ),
      ),
    );
  }
}
