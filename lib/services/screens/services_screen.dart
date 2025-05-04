import 'package:flutter/material.dart';
import 'package:test/chat/screens/chat_list_screen.dart';
import 'package:test/chat/screens/chat_screen.dart';
import 'package:test/services/screens/abscence_screen.dart';
import 'package:test/services/screens/attendance_screen.dart';
import 'package:test/services/screens/documents_screen.dart';
import 'package:test/services/screens/payments_screen.dart';
import 'package:test/user/domain/user_preferences.dart';

class ServicesPage extends StatelessWidget {
  ServicesPage({Key? key}) : super(key: key);

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case '/':
              builder = (BuildContext _) => _servicesGrid(context);
              break;
            case '/documents':
              builder = (BuildContext _) => const DocumentsListScreen();
              break;
            case '/absence':
              builder = (BuildContext _) => const AbsenceRequestScreen();
              break;
            case '/income':
              builder = (BuildContext _) => const PaymentsScreen();
              break;
            case '/attendance':
              builder = (BuildContext _) => const AttendanceScreen();
              break;
            case '/chat_list':
              builder = (BuildContext _) => const ChatListScreen();
              break;
            default:
              throw Exception('Invalid route: ${settings.name}');
          }
          return MaterialPageRoute(builder: builder, settings: settings);
        },
      ),
    );
  }

  Widget _servicesGrid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        centerTitle: true,
        title: const Text(
          'Сервисы',
          style: TextStyle(
            fontFamily: 'CeraPro',
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),

      ),
      body: SafeArea(
        child: FutureBuilder<String?>(
          future: UserPreferences.getRole(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              final role = snapshot.data;
              return GridView.count(
                crossAxisCount: 2,
                childAspectRatio: (1 / 1.2),
                padding: const EdgeInsets.all(16),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildServiceButton(
                    context,
                    'assets/images/income_icon.png',
                    'Мои доходы',
                    '/income',
                  ),
                  _buildServiceButton(
                    context,
                    'assets/images/documents_icon.png',
                    'Мои документы',
                    '/documents',
                  ),
                  _buildServiceButton(
                    context,
                    'assets/images/vacation_icon.png',
                    'Отпуска',
                    '/absence',
                  ),
                  _buildServiceButton(
                    context,
                    'assets/images/chat_icon.png',
                    'Мессенджер',
                    '/chat_list',
                  ),
                  if (role == 'manager')
                    _buildServiceButton(
                      context,
                      'assets/images/attendance_icon.png',
                      'Табель',
                      '/attendance',
                    ),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget _buildServiceButton(
    BuildContext context,
    String iconPath,
    String label,
    String routeName,
  ) {
    return Card(
      shadowColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToLocalRoute(context, routeName),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.3,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 22, 79, 148),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Image.asset(iconPath, fit: BoxFit.contain),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 27),
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'CeraPro',
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToLocalRoute(BuildContext context, String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }
}
