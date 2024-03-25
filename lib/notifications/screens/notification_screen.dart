import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:test/notifications/data/notification.dart';
import 'package:test/notifications/screens/pdf_view_screen.dart';
import 'package:test/user/domain/user_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async';

enum FilterType {
  byType,
  byDate,
  vacationRequest,
  vacationApproved,
  vacationDenied,
  attendanceAdded
}

class NoticePage extends StatefulWidget {
  const NoticePage({super.key});

  @override
  NoticePageState createState() => NoticePageState();
}

class NoticePageState extends State<NoticePage> {
  final GlobalKey<NavigatorState> _noticeNavigatorKey =
      GlobalKey<NavigatorState>();
  Future<NotificationsResponse>? futureNotifications;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    loadNotifications();
    _timer = Timer.periodic(
        const Duration(seconds: 5), (Timer t) => loadNotifications());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void loadNotifications() async {
    String? token = await UserPreferences.getToken();
    if (token != null) {
      fetchNotifications(token).then((notificationsResponse) {
        notificationsResponse.notifications.sort((a, b) {
          return b.created.compareTo(a.created);
        });
        setState(() {
          futureNotifications = Future.value(notificationsResponse);
        });
      }).catchError((error) {
        setState(() {
          futureNotifications = Future.error('Ошибка загрузки уведомлений');
        });
      });
    } else {
      setState(() {
        futureNotifications = Future.error('Токен не найден');
      });
    }
  }

  void applyFilter(FilterType filterType, {bool ascending = false}) async {
    String? token = await UserPreferences.getToken();
    if (token == null) {
      setState(() {
        futureNotifications =
            Future<NotificationsResponse>.error('Токен не найден');
        return;
      });
    }

    futureNotifications =
        fetchNotifications(token!).then((notificationsResponse) {
      List<NotificationModel> notifications =
          notificationsResponse.notifications;

      if (filterType == FilterType.byDate) {
        notifications.sort((a, b) {
          DateTime dateA = DateTime.parse(a.created);
          DateTime dateB = DateTime.parse(b.created);
          return ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
        });
      } else if (filterType != FilterType.byType) {
        notifications = notifications
            .where((notification) =>
                matchesFilterType(notification.type, filterType))
            .toList();
      }
      notifications.sort((a, b) => b.created.compareTo(a.created));
      return NotificationsResponse(notifications: notifications);
    });

    setState(() {});
  }

  bool matchesFilterType(String notificationType, FilterType filterType) {
    switch (filterType) {
      case FilterType.vacationRequest:
        return notificationType == 'vacation_request';
      case FilterType.vacationApproved:
        return notificationType == 'vacation_approved';
      case FilterType.vacationDenied:
        return notificationType == 'vacation_denied';
      case FilterType.attendanceAdded:
        return notificationType == 'attendance_added';
      default:
        return false;
    }
  }

  Future<NotificationsResponse> fetchNotifications(String token) async {
    const url = 'http://51.250.110.96:8080/v1/notifications';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> json = jsonDecode(responseBody);
      return NotificationsResponse.fromJson(json);
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 245, 245, 245),
          title: const Text(
            'Фильтр уведомлений',
            style: TextStyle(
              fontFamily: 'CeraPro',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  title: const Text(
                    'Все уведомления',
                    style: TextStyle(
                      fontFamily: 'CeraPro',
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    applyFilter(FilterType.byType);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text(
                    'Запросы на отпуск',
                    style: TextStyle(
                      fontFamily: 'CeraPro',
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    applyFilter(FilterType.vacationRequest);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text(
                    'Запрос принят',
                    style: TextStyle(
                      fontFamily: 'CeraPro',
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    applyFilter(FilterType.vacationApproved);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text(
                    'Запрос отклонен',
                    style: TextStyle(
                      fontFamily: 'CeraPro',
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    applyFilter(FilterType.vacationDenied);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text(
                    'Посещаемость',
                    style: TextStyle(
                      fontFamily: 'CeraPro',
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    applyFilter(FilterType.attendanceAdded);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text(
                    'По дате (старые)',
                    style: TextStyle(
                      fontFamily: 'CeraPro',
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    applyFilter(FilterType.byDate, ascending: true);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _noticeNavigatorKey,
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (context) => _buildNoticeContent());
        } else if (settings.name == '/pdfView') {
          final File file = settings.arguments as File;
          return MaterialPageRoute(
            builder: (context) => PDFViewPage(file: file),
          );
        }
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
    );
  }

  Widget _buildNoticeContent() {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Уведомления',
            style: TextStyle(
              fontFamily: 'CeraPro',
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                _showFilterDialog();
              },
            ),
          ],
        ),
        body: FutureBuilder<NotificationsResponse>(
          future: futureNotifications,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Ошибка: ${snapshot.error}"));
            } else if (snapshot.hasData &&
                snapshot.data!.notifications.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.notifications.length,
                itemBuilder: (BuildContext context, int index) {
                  final notification = snapshot.data!.notifications[index];
                  return NotificationCard(
                    notification: notification,
                    navigatorKey: _noticeNavigatorKey,
                  );
                },
              );
            } else {
              return const Center(child: Text('Нет доступных уведомлений.'));
            }
          },
        ));
  }
}

class NotificationCard extends StatefulWidget {
  final NotificationModel notification;
  final GlobalKey<NavigatorState> navigatorKey;

  const NotificationCard({
    Key? key,
    required this.notification,
    required this.navigatorKey,
  }) : super(key: key);

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  Future<String?> fetchVacationDocumentLink(
      String token, String actionId, String requestType) async {
    const url = 'http://51.250.110.96:8080/v1/documents/vacation';
    final uri = Uri.parse(url).replace(queryParameters: {
      'action_id': actionId,
      'request_type': requestType,
    });
    final response =
        await http.get(uri, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      return response.body;
    } else {
      // ignore: avoid_print
      print('Ошибка запроса документа: ${response.statusCode}');
      return null;
    }
  }

  void markAsRead(String id) async {
    String? token = await UserPreferences.getToken();
    if (token == null) return;

    const url = 'http://51.250.110.96:8080/v1/notifications';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode == 200) {
      setState(() {
        widget.notification.isRead = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось отметить уведомление как прочитанное.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!widget.notification.isRead) {
          markAsRead(widget.notification.id);
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage:
                            widget.notification.sender.photo_link != null
                                ? NetworkImage(
                                    widget.notification.sender.photo_link!)
                                : null,
                        child: widget.notification.sender.photo_link == null
                            ? const Icon(Icons.person, size: 25)
                            : null,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          '${widget.notification.sender.name} ${widget.notification.sender.surname}',
                          style: const TextStyle(
                            fontFamily: 'CeraPro',
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatDateTime(widget.notification.created),
                        style: const TextStyle(
                          fontFamily: 'CeraPro',
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.notification.text,
                    style: const TextStyle(
                      fontFamily: 'CeraPro',
                      fontSize: 16.0,
                    ),
                  ),
                  if (widget.notification.type == 'vacation_request')
                    Column(
                      children: [
                        const SizedBox(height: 16.0),
                        _buildActionButtons(
                            context, widget.notification.actionId),
                      ],
                    ),
                  if (widget.notification.type == 'vacation_approved')
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 46),
                      child: ElevatedButton(
                        onPressed: () => _viewPdfDocument(
                            context, widget.notification.actionId, "create"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 22, 79, 148),
                        ),
                        child: const Text(
                          'Просмотреть PDF документ',
                          style: TextStyle(
                              fontFamily: 'CeraPro',
                              color: Color.fromARGB(255, 245, 245, 245)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (!widget.notification.isRead)
            Positioned(
              right: 18,
              top: 13,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 22, 79, 148),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String actionId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await sendAbsenceVerdict(actionId, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Отпуск утвержден')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Разрешить',
                style: TextStyle(
                  fontFamily: 'CeraPro',
                  color: Color.fromARGB(255, 245, 245, 245),
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        // Deny button
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await sendAbsenceVerdict(actionId, false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Отпуск отклонен')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Отказать',
                style: TextStyle(
                  fontFamily: 'CeraPro',
                  color: Color.fromARGB(255, 245, 245, 245),
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _viewPdfDocument(
      BuildContext context, String actionId, String requestType) async {
    String? token = await UserPreferences.getToken();
    if (token != null) {
      try {
        String? fileUrl =
            await fetchVacationDocumentLink(token, actionId, requestType);
        if (fileUrl != null) {
          File pdfFile = await downloadFile(fileUrl);
          widget.navigatorKey.currentState?.pushNamed(
            '/pdfView',
            arguments: pdfFile,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("PDF документ не найден.")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ошибка при открытии документа: $e")),
        );
      }
    }
  }

  Future<File> downloadFile(String url) async {
    var response = await http.get(Uri.parse(url));
    var bytes = response.bodyBytes;
    var dir = await getApplicationDocumentsDirectory();
    File file = File('${dir.path}/document.pdf');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  String _formatDateTime(String dateTime) {
    DateTime parsedDate = DateTime.parse(dateTime);
    DateFormat formatter = DateFormat('dd.MM.yyyy');
    return formatter.format(parsedDate);
  }

  Future<bool> sendAbsenceVerdict(String actionId, bool approve) async {
    String? token = await UserPreferences.getToken();
    if (token == null) {
      throw Exception('Токен не найден');
    }

    const url = 'http://51.250.110.96:8080/v1/abscence/verdict';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode({
        'action_id': actionId,
        'approve': approve,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Ошибка при отправке решения: ${response.body}');
    }
  }
}
