// ignore: file_names
class UserAction {
  final String id;
  final String type;
  final String startDate;
  final String endDate;

  UserAction({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
  });

  factory UserAction.fromJson(Map<String, dynamic> json) {
    return UserAction(
      id: json['id'] as String,
      type: json['type'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
    );
  }
}
