import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/services/data/payment.dart';
import 'package:test/services/domain/payment_service.dart';

final paymentProvider = FutureProvider<List<Payment>>((ref) async {
  return await PaymentApi.getPayments();
});
