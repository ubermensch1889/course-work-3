class AttendanceRecord {
  final String employeeId;
  final String name;
  final String surname;
  final String? patronymic;
  final DateTime? startDate;
  final DateTime? endDate;

  AttendanceRecord({
    required this.employeeId,
    required this.name,
    required this.surname,
    this.patronymic,
    this.startDate,
    this.endDate,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    var employee = json['employee'];
    return AttendanceRecord(
      employeeId: employee['id'],
      name: employee['name'],
      surname: employee['surname'],
      patronymic: employee['patronymic'],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
    );
  }
}
