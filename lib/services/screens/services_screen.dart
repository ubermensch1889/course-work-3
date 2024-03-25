import 'package:flutter/material.dart';
import 'package:test/services/screens/abscence_screen.dart';
import 'package:test/services/screens/documents_screen.dart';
import 'package:test/services/screens/payments_screen.dart';

class ServicesPage extends StatelessWidget {
  ServicesPage({Key? key}) : super(key: key);

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: Navigator(
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
            default:
              throw Exception('Invalid route: ${settings.name}');
          }
          return MaterialPageRoute(builder: builder, settings: settings);
        },
      ),
    );
  }

  Widget _servicesGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: (1 / 1.2),
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildServiceButton(
          _navigatorKey.currentState?.context ?? context,
          'assets/images/income_icon.png',
          'Мои доходы',
          '/income',
        ),
        _buildServiceButton(
          _navigatorKey.currentState?.context ?? context,
          'assets/images/documents_icon.png',
          'Мои документы',
          '/documents',
        ),
        _buildServiceButton(
          _navigatorKey.currentState?.context ?? context,
          'assets/images/vacation_icon.png',
          'Отпуска',
          '/absence',
        ),
      ],
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
