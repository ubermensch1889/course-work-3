import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:test/services/data/payment.dart';
import 'package:test/services/domain/payment_provider.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    initializeDateFormatting('ru_RU', null);

    AsyncValue<List<Payment>> payments = ref.watch(paymentProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Мои доходы',
            style: TextStyle(
              fontFamily: 'CeraPro',
              fontSize: 22,
              fontWeight: FontWeight.bold,
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: payments.when(
        data: (data) {
          final paymentsByMonth = groupByMonth(data);

          return ListView.builder(
            itemCount: paymentsByMonth.length,
            itemBuilder: (context, index) {
              final month = paymentsByMonth.keys.elementAt(index);
              final monthPayments = paymentsByMonth[month]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      month,
                      style: const TextStyle(
                        fontFamily: 'CeraPro',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  ...monthPayments.map((payment) {
                    final String sign = payment.amount >= 0 ? '+' : '-';
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 22, 79, 148),
                        child: Icon(Icons.business, color: Colors.white),
                      ),
                      title: Text(
                          DateFormat.yMMMMd('ru_RU')
                              .format(payment.payrollDate),
                          style: const TextStyle(
                            fontFamily: 'CeraPro',
                            fontSize: 18,
                          )),
                      subtitle: const Text('Компания',
                          style: TextStyle(
                            fontFamily: 'CeraPro',
                            fontSize: 16,
                          )),
                      trailing: Text(
                        '$sign${payment.amount.toString()} ₽',
                        style: const TextStyle(
                            color: Colors.green,
                            fontFamily: 'CeraPro',
                            fontSize: 18),
                      ),
                    );
                  }),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Map<String, List<Payment>> groupByMonth(List<Payment> payments) {
    final Map<String, List<Payment>> grouped = {};
    for (final payment in payments) {
      final month =
          DateFormat('MMMM yyyy', 'ru_RU').format(payment.payrollDate);
      if (grouped[month] == null) {
        grouped[month] = [];
      }
      grouped[month]!.add(payment);
    }
    return grouped;
  }
}
