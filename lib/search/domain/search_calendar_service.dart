import 'package:test/user/data/user_action.dart';
import 'package:test/user/domain/user_preferences.dart';

class SearchCalendarService {
  Future<Map<DateTime, List<UserAction>>> fetchUserActionsForCalendar(
      DateTime start, DateTime end, String userId) async {
    final from = start.toIso8601String();
    final to = end.toIso8601String();

    final userActions =
        await UserPreferences.fetchUserActions(from, to, userId);

    final Map<DateTime, List<UserAction>> events = {};
    for (final action in userActions) {
      DateTime startDate = DateTime.parse(action.startDate);
      DateTime endDate = DateTime.parse(action.endDate);
      List<DateTime> listOfDays = _getDaysInBetween(startDate, endDate);

      for (DateTime date in listOfDays) {
        final dateKey = DateTime.utc(date.year, date.month, date.day);
        events.putIfAbsent(dateKey, () => []).add(action);
      }
    }
    return events;
  }

  List<DateTime> _getDaysInBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(DateTime.utc(startDate.year, startDate.month, startDate.day)
          .add(Duration(days: i)));
    }
    return days;
  }
}
