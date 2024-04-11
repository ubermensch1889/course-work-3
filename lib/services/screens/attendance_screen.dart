import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:test/services/data/attendance.dart';
import 'package:test/services/domain/attendance_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  AttendanceScreenState createState() => AttendanceScreenState();
}

class AttendanceScreenState extends State<AttendanceScreen> {
  final List<AttendanceRecord> _attendances = [];
  bool _isLoading = false;
  DateTime? _selectedDate;

  final Map<String, TextEditingController> _startControllers = {};
  final Map<String, TextEditingController> _endControllers = {};
  final Map<String, bool> _absenceStatus = {};

  @override
  void dispose() {
    _startControllers.forEach((_, controller) => controller.dispose());
    _endControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _saveAttendance(
      String employeeId, DateTime startDate, DateTime endDate) async {
    if (_absenceStatus[employeeId] == true) {
      _showErrorDialog('Сотрудник отсутствовал, сохранение не требуется.');
      return;
    }
    try {
      String formattedStart =
          DateFormat('yyyy-MM-ddTHH:mm:ss').format(startDate);
      String formattedEnd = DateFormat('yyyy-MM-ddTHH:mm:ss').format(endDate);
      await AttendanceService.addAttendance(
          employeeId, formattedStart, formattedEnd);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Посещение сохранено')),
      );
    } catch (e) {
      _showErrorDialog('Ошибка добавления посещения: $e');
    }
  }

  void _toggleAbsence(String employeeId) {
    setState(() {
      _absenceStatus[employeeId] = !(_absenceStatus[employeeId] ?? false);
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadAttendances();
  }

  Future<void> _loadAttendances() async {
    if (_selectedDate == null) {
      _showErrorDialog('Дата не выбрана.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String start = DateFormat('yyyy-MM-ddT00:00:00').format(_selectedDate!);
      String end = DateFormat('yyyy-MM-ddT23:59:59').format(_selectedDate!);

      List<AttendanceRecord> attendances =
          await AttendanceService.fetchAllAttendances(start, end);

      // Initialize text controllers with server-provided times
      for (var attendance in attendances) {
        _startControllers[attendance.employeeId] = TextEditingController(
            text: attendance.startDate != null
                ? DateFormat('HH:mm').format(attendance.startDate!)
                : '');
        _endControllers[attendance.employeeId] = TextEditingController(
            text: attendance.endDate != null
                ? DateFormat('HH:mm').format(attendance.endDate!)
                : '');
      }

      setState(() {
        _attendances.clear();
        _attendances.addAll(attendances);
      });
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Табель',
            style: TextStyle(
              fontFamily: 'CeraPro',
              fontSize: 22,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 22, 79, 148),
                      ),
                      onPressed: () => _selectDate(context),
                      child: Text(
                        'Дата: ${_selectedDate!.day.toString().padLeft(2, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.year}',
                        style: const TextStyle(
                            fontFamily: 'CeraPro',
                            color: Color.fromARGB(255, 245, 245, 245)),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 22, 79, 148),
                  ),
                  onPressed: _loadAttendances,
                  child: const Text('Загрузить табель',
                      style: TextStyle(
                          fontFamily: 'CeraPro',
                          color: Color.fromARGB(255, 245, 245, 245))),
                ),
              ],
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _attendances.length,
                      itemBuilder: (context, index) {
                        var attendance = _attendances[index];
                        var employeeId = attendance.employeeId;

                        DateTime now = DateTime.now();
                        String defaultTime = DateFormat('HH:mm').format(now);

                        _startControllers.putIfAbsent(employeeId,
                            () => TextEditingController(text: defaultTime));
                        _endControllers.putIfAbsent(employeeId,
                            () => TextEditingController(text: defaultTime));

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        '${attendance.name} ${attendance.surname} ${attendance.patronymic ?? ""}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: TextField(
                                        controller:
                                            _startControllers[employeeId],
                                        decoration: const InputDecoration(
                                          labelText: 'Начало',
                                          hintText: 'HH:mm',
                                        ),
                                        keyboardType: TextInputType.datetime,
                                        enabled: !(_absenceStatus[employeeId] ??
                                            false),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: TextField(
                                        controller: _endControllers[employeeId],
                                        decoration: const InputDecoration(
                                          labelText: 'Конец',
                                          hintText: 'HH:mm',
                                        ),
                                        keyboardType: TextInputType.datetime,
                                        enabled: !(_absenceStatus[employeeId] ??
                                            false),
                                      ),
                                    ),
                                    Expanded(
                                      child: IconButton(
                                        icon: const FaIcon(
                                            FontAwesomeIcons.userSlash),
                                        onPressed: () =>
                                            _toggleAbsence(employeeId),
                                        color:
                                            _absenceStatus[employeeId] == true
                                                ? Colors.red
                                                : Colors.black,
                                      ),
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: IconButton(
                                          icon: const FaIcon(
                                              FontAwesomeIcons.solidFloppyDisk),
                                          onPressed: () {
                                            if (_startControllers[employeeId]
                                                        ?.text
                                                        .isNotEmpty ==
                                                    true &&
                                                _endControllers[employeeId]
                                                        ?.text
                                                        .isNotEmpty ==
                                                    true) {
                                              try {
                                                String startDateString =
                                                    _startControllers[
                                                            employeeId]!
                                                        .text;
                                                String endDateString =
                                                    _endControllers[employeeId]!
                                                        .text;

                                                // Assuming the date is selected using _selectedDate and the time is entered in HH:mm format
                                                DateTime startDate = DateFormat(
                                                        'yyyy-MM-dd HH:mm')
                                                    .parse(
                                                  '${_selectedDate!.toIso8601String().split('T')[0]} $startDateString',
                                                );
                                                DateTime endDate = DateFormat(
                                                        'yyyy-MM-dd HH:mm')
                                                    .parse(
                                                  '${_selectedDate!.toIso8601String().split('T')[0]} $endDateString',
                                                );

                                                _saveAttendance(employeeId,
                                                    startDate, endDate);
                                              } catch (e) {
                                                _showErrorDialog(
                                                    'Ошибка парсинга времени: $e');
                                              }
                                            } else {
                                              _showErrorDialog(
                                                  'Время начала или окончания отсутствует.');
                                            }
                                          },
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAttendances();
    }
  }
}
