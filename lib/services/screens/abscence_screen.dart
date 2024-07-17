import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test/services/domain/abscence_service.dart';

class AbsenceRequestScreen extends StatefulWidget {
  const AbsenceRequestScreen({super.key});

  @override
  AbsenceRequestScreenState createState() => AbsenceRequestScreenState();
}

class AbsenceRequestScreenState extends State<AbsenceRequestScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  TextEditingController? _startDateController;
  TextEditingController? _endDateController;

  @override
  void initState() {
    super.initState();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
  }

  @override
  void dispose() {
    _startDateController?.dispose();
    _endDateController?.dispose();
    super.dispose();
  }

  void clearDates() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _startDateController?.clear();
      _endDateController?.clear();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? _startDate ?? DateTime.now()
          : _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 22, 79, 148),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 22, 79, 148),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (isStartDate) {
        if (_endDate != null && picked.isAfter(_endDate!)) {
          _showDateError();
          return;
        }
        _startDate = picked;
      } else {
        if (_startDate != null && picked.isBefore(_startDate!)) {
          _showDateError();
          return;
        }
        _endDate = picked;
      }

      setState(() {
        if (isStartDate) {
          _startDateController?.text = _dateFormat.format(picked);
        } else {
          _endDateController?.text = _dateFormat.format(picked);
        }
      });
    }
  }

  void _showDateError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка'),
        content: const Text(
            'Дата окончания отпуска не может быть раньше даты начала.'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
      String label, TextEditingController? controller, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 56.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF164F94),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              suffixIcon: const Icon(Icons.calendar_today, color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(4.0),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            ),
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 16.0),
          ),
        ),
      ),
    );
  }

  void _requestAbsence() async {
    if (_startDate != null && _endDate != null) {
      final success = await AbsenceService.requestAbsence(
        _startDate!,
        _endDate!,
        'vacation',
      );

      if (success) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Успех'),
            content: const Text('Заявка на отпуск отправлена успешно!'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Ошибка'),
            content:
                const Text('Возникла ошибка при попытке отправить заявку!'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Отпуска',
            style: TextStyle(
              fontFamily: 'CeraPro',
              fontSize: 22,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            width: 328.0,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF164F94), Color(0xFF164F94)],
              ),
              borderRadius: BorderRadius.circular(28.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Выберите дату',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 36.0),
                _buildDateField(
                  'Начало',
                  _startDateController,
                  () => _selectDate(context, true),
                ),
                _buildDateField(
                  'Конец',
                  _endDateController,
                  () => _selectDate(context, false),
                ),
                const SizedBox(height: 36.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      onPressed: clearDates,
                      child: const Text('Отмена'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color(0xFF164F94),
                        backgroundColor: Colors.white,
                      ),
                      onPressed: _startDate != null && _endDate != null
                          ? _requestAbsence
                          : null,
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
