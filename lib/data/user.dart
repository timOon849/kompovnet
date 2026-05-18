class User {
  int Id;
  final String name;
  final String lastName;
  final String login;
  final String password;
  final String phone;
  double balance;

  User({
    required this.name,
    required this.Id,
    required this.lastName,
    required this.login,
    required this.password,
    this.phone = '',
    this.balance = 0.0,
  });

  User copyWith({String? name, String? lastName, String? phone}) {
    return User(
      Id: Id,
      login: login,
      password: password,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      balance: balance,
    );
  }
}