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
      id: json['id'],
      type: json['type'],
      isRead: json['is_read'],
      text: json['text'],
      created: json['created'],
      actionId: json['action_id'],
      sender: Employee.fromJson(json['sender']),
    );
  }
}

class NotificationsResponse {
  List<NotificationModel> notifications;

  NotificationsResponse({required this.notifications});

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    var list = json['notifications'] as List;
    List<NotificationModel> notificationsList =
        list.map((i) => NotificationModel.fromJson(i)).toList();
    return NotificationsResponse(notifications: notificationsList);
  }
}
