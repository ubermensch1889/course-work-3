// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:test/calendar/domain/calendar_service.dart';
import 'package:test/notifications/data/notification.dart';
import 'package:test/notifications/domain/notification_service.dart';
import 'package:test/user/data/user_action.dart';
import 'package:test/user/domain/user_preferences.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  final CalendarService _calendarService = CalendarService();
  Map<DateTime, List<UserAction>> _events = {};
  List<UserAction> _selectedEvents = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final ValueNotifier<Set<String>> _approvedVacationIds = ValueNotifier({});

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([
      _fetchUserActions(),
      _fetchApprovedVacations(),
    ]);
  }

  Future<void> _fetchUserActions() async {
    DateTime firstDayOfCurrentMonth =
        DateTime(_focusedDay.year, _focusedDay.month, 1);
    DateTime lastDayOfNextMonth =
        DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    _events = await _calendarService.fetchUserActionsForCalendar(
        firstDayOfCurrentMonth, lastDayOfNextMonth);
    setState(() {});
  }

  Future<void> _fetchApprovedVacations() async {
    String? token = await UserPreferences.getToken();
    if (token == null) {
      print('Token not found');
      return;
    }
    var notificationService = NotificationService();
    try {
      NotificationsResponse response =
          await notificationService.fetchNotifications(token);
      var newApprovedIds = response.notifications
          .where((notif) => notif.type == 'vacation_approved')
          .map((notif) => notif.actionId)
          .toSet();

      _approvedVacationIds.value = newApprovedIds;
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Календарь',
          style: TextStyle(
              fontFamily: 'CeraPro', fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          ValueListenableBuilder<Set<String>>(
            valueListenable: _approvedVacationIds,
            builder: (context, approvedIds, _) {
              return TableCalendar<UserAction>(
                locale: 'ru_RU',
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                headerStyle: const HeaderStyle(formatButtonVisible: false),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                eventLoader: (day) =>
                    _events[day]
                        ?.where((event) => approvedIds.contains(event.id))
                        .toList() ??
                    [],
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      Color markerColor = Colors.transparent;
                      for (UserAction event in events) {
                        markerColor = event.type == 'attendance'
                            ? Colors.green
                            : Colors.purple;
                      }
                      return Positioned(
                        right: 1,
                        top: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: markerColor,
                          ),
                          width: 8.0,
                          height: 8.0,
                        ),
                      );
                    }
                    return null;
                  },
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedEvents = _events[selectedDay] ?? [];
                  });
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                  _fetchUserActions();
                },
              );
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedEvents.length,
              itemBuilder: (context, index) {
                final event = _selectedEvents[index];
                return ListTile(
                  title: Text(
                    event.type == 'attendance'
                        ? 'Работа: ${formatDate(event.startDate)} до ${formatDate(event.endDate)}'
                        : 'Отпуск: ${formatDate(event.startDate)} до ${formatDate(event.endDate)}',
                    style: TextStyle(
                      color: event.type == 'attendance'
                          ? Colors.green
                          : Colors.purple,
                    ),
                  ),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(String dateStr) {
    final dateTime = DateTime.parse(dateStr);
    final formatter = DateFormat('dd MMM yyyy, HH:mm', 'ru_RU');
    return formatter.format(dateTime);
  }
}
