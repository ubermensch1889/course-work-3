class User {
  final String id;
  final String name;
  final String surname;
  final String? patronymic;
  final List<String>? phones;
  final String? email;
  final String? birthday;
  // ignore: non_constant_identifier_names
  final String? photo_link;
  final String? password;
  final String? headId;
  // ignore: non_constant_identifier_names
  final String? telegram_id;
  // ignore: non_constant_identifier_names
  final String? vk_id;
  final String? team;

  User(
      {required this.id,
      required this.name,
      required this.surname,
      required this.patronymic,
      required this.phones,
      required this.email,
      required this.birthday,
      // ignore: non_constant_identifier_names
      required this.photo_link,
      required this.password,
      required this.headId,
      // ignore: non_constant_identifier_names
      required this.telegram_id,
      // ignore: non_constant_identifier_names
      required this.vk_id,
      required this.team});

  factory User.fromJson(Map<String, dynamic> json) {
    var phonesFromJson = json['phones'];
    List<String> phoneList = [];
    if (phonesFromJson != null) {
      phoneList =
          List<String>.from(phonesFromJson.map((phone) => phone.toString()));
    }
    return User(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      patronymic: json['patronymic'],
      phones: phoneList,
      email: json['email'],
      birthday: json['birthday'],
      photo_link: json['photo_link'],
      headId: json['headId'],
      password: json['password'],
      team: json['team'],
      telegram_id: json['telegram_id'],
      vk_id: json['vk_id'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is User) {
      return id == other.id;
    }

    return false;
  }

  String getFullName() {
    if (patronymic != null) {
      return '$surname $name $patronymic';
    }

    return '$name $surname';
  }
}
