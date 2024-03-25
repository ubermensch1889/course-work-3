class Employee {
  final String? id;
  final String? name;
  final String? surname;
  final String? patronymic;
  // ignore: non_constant_identifier_names
  final String? photo_link;

  Employee({
    required this.id,
    required this.name,
    required this.surname,
    this.patronymic,
    // ignore: non_constant_identifier_names
    this.photo_link,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      patronymic: json['patronymic'],
      photo_link: json['photo_link'],
    );
  }
}
