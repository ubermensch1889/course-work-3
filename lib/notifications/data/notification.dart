import 'package:test/notifications/data/notification_employee.dart';

class NotificationModel {
  final String id;
  final String type;
  bool isRead;
  final String text;
  final String created;
  final String actionId;
  final Employee sender;

  NotificationModel({
    required this.id,
    required this.type,
    required this.isRead,
    required this.text,
    required this.created,
    required this.actionId,
    required this.sender,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ??
          'default_id', // Укажите здесь адекватные значения по умолчанию
      type: json['type'] as String? ?? 'default_type',
      isRead: json['is_read'] ??
          false, // Если isRead может быть null, установите значение по умолчанию
      text: json['text'] as String? ?? 'default_text',
      created: json['created'] as String? ?? 'default_created',
      actionId: json['action_id'] as String? ?? 'default_action_id',
      sender: Employee.fromJson(json['sender'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class NotificationsResponse {
  final List<NotificationModel> notifications;

  NotificationsResponse({required this.notifications});

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    var list = json['notifications'] as List;
    List<NotificationModel> notificationsList =
        list.map((i) => NotificationModel.fromJson(i)).toList();
    return NotificationsResponse(notifications: notificationsList);
  }
}
