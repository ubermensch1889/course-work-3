class Payment {
  final String id;
  final String userId;
  final double amount;
  final DateTime payrollDate;

  Payment({
    required this.id,
    required this.userId,
    required this.amount,
    required this.payrollDate,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      userId: json['user_id'],
      amount: (json['amount'] as num).toDouble(),
      payrollDate: DateTime.parse(json['payroll_date']),
    );
  }
}
