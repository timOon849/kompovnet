import 'package:flutter/material.dart';
import 'package:kompovnet/data/mock_data.dart';
import 'package:kompovnet/services/kompov_repository.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = currentClient.FirstName;
    _lastnameController.text = currentClient.LastName;
    _phoneController.text = currentClient.PhoneNumber ?? '';
    _nameController.addListener(_onFieldChanged);
    _lastnameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _lastnameController.removeListener(_onFieldChanged);
    _phoneController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _lastnameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    setState(() {});
  }

  bool get _hasChanges {
    return _nameController.text.trim() != currentClient.FirstName ||
        _lastnameController.text.trim() != currentClient.LastName ||
        _phoneController.text.trim() != (currentClient.PhoneNumber ?? '');
  }

  String? _validateName(String? value, String label) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Укажите $label';
    }
    if (trimmed.length < 2) {
      return '$label слишком коротк${label == "Имя" ? "ое" : "ая"}';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }

    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10 || digitsOnly.length > 11) {
      return 'Введите корректный номер телефона';
    }

    return null;
  }

  String _normalizePhone(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  Future<void> _saveProfile() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final firstName = _nameController.text.trim();
    final lastName = _lastnameController.text.trim();
    final phone = _phoneController.text.trim();

    currentClient.FirstName = firstName;
    currentClient.LastName = lastName;
    currentClient.PhoneNumber = phone.isEmpty ? null : phone;

    try {
      await KompovRepository.instance.updateClient(currentClient);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Изменения успешно сохранены')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сохранения: $e')),
      );
    }
  }

  Future<void> _closePage() async {
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Отменить изменения?'),
        content: const Text('Несохраненные изменения будут потеряны.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Продолжить редактирование'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Выйти без сохранения'),
          ),
        ],
      ),
    );

    if (shouldClose == true && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование профиля'),
        leading: IconButton(
          onPressed: _closePage,
          icon: const Icon(Icons.close_sharp),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Имя',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => _validateName(value, 'Имя'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastnameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Фамилия',
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) => _validateName(value, 'Фамилия'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Телефон',
                  hintText: '+7 (900) 123-45-67',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: _validatePhone,
              ),
              const SizedBox(height: 6),
              const Text(
                'Телефон можно оставить пустым.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                ),
                onPressed: _hasChanges ? _saveProfile : null,
                child: const Text('Сохранить изменения'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
