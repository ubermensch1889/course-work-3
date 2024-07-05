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

  final Map<String, TextEditingController> _hoursWorkedControllers = {};
  final Map<String, bool> _absenceStatus = {};

  @override
  void dispose() {
    _hoursWorkedControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _saveAttendance(String employeeId, int hoursWorked) async {
    if (_absenceStatus[employeeId] == true) {
      _showErrorDialog('Сотрудник отсутствовал, сохранение не требуется.');
      return;
    }
    try {
      DateTime startDate = DateTime(
          _selectedDate!.year, _selectedDate!.month, _selectedDate!.day, 9);
      DateTime endDate = startDate.add(Duration(hours: hoursWorked));

      String formattedStart =
          DateFormat('yyyy-MM-ddTHH:mm:ss').format(startDate);
      String formattedEnd = DateFormat('yyyy-MM-ddTHH:mm:ss').format(endDate);
      await AttendanceService.addAttendance(
          employeeId, formattedStart, formattedEnd);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Данные успешно сохранены!'),
          backgroundColor: Color.fromARGB(255, 22, 79, 148),
          behavior: SnackBarBehavior.fixed,
        ),
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

      setState(() {
        _attendances.clear();
        _attendances.addAll(attendances);
        for (var attendance in _attendances) {
          int hoursWorked = 0;
          if (attendance.startDate != null && attendance.endDate != null) {
            Duration difference =
                attendance.endDate!.difference(attendance.startDate!);
            hoursWorked = difference.inHours;
          }
          _hoursWorkedControllers[attendance.employeeId] =
              TextEditingController(text: hoursWorked.toString());

          _absenceStatus[attendance.employeeId] = false;
        }
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
                        'Дата: ${_selectedDate?.day.toString().padLeft(2, '0')}-${_selectedDate?.month.toString().padLeft(2, '0')}-${_selectedDate?.year}',
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

                        _hoursWorkedControllers[attendance.employeeId] =
                            TextEditingController(text: '');

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(
                              color: _absenceStatus[employeeId] == true
                                  ? Colors.red
                                  : const Color.fromARGB(255, 22, 79, 148),
                              width: 1.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${attendance.surname} ${attendance.name} ${attendance.patronymic ?? ""}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Row(
                                  children: [
                                    const Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Отработано часов:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: TextField(
                                        controller:
                                            _hoursWorkedControllers[employeeId],
                                        decoration: const InputDecoration(
                                          labelText: 'Часы',
                                          hintText: '0',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 4.0, horizontal: 8.0),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    Expanded(
                                      child: IconButton(
                                        icon: FaIcon(
                                          FontAwesomeIcons.userSlash,
                                          color:
                                              _absenceStatus[employeeId] == true
                                                  ? Colors.red
                                                  : Colors.black,
                                        ),
                                        onPressed: () =>
                                            _toggleAbsence(employeeId),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        icon: const FaIcon(
                                          FontAwesomeIcons.solidFloppyDisk,
                                          color:
                                              Color.fromARGB(255, 22, 79, 148),
                                        ),
                                        onPressed: () {
                                          final hoursWorkedText =
                                              _hoursWorkedControllers[
                                                          employeeId]
                                                      ?.text ??
                                                  '';
                                          final hoursWorked =
                                              int.tryParse(hoursWorkedText) ??
                                                  0;
                                          _saveAttendance(
                                              employeeId, hoursWorked);
                                        },
                                      ),
                                    ),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAttendances();
    }
  }
}
