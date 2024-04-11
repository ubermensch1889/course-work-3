import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:test/auth/domain/auth_manager.dart';
import 'package:test/calendar/screens/calendar_screen.dart';
import 'package:test/start/data/navigator_check.dart';
import 'package:test/start/screens/nav_bar.dart';
import 'package:test/notifications/screens/notification_screen.dart';
import 'package:test/profile/screens/profile_screen.dart';
import 'package:test/search/screens/search_screen.dart';
import 'package:test/services/screens/services_screen.dart';
import 'package:test/start/screens/start_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru_RU', null);

  HttpOverrides.global = _MyHttpOverrides();

  runApp(const ProviderScope(child: MyApp()));
}

class _MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

final authStateProvider = StateProvider<bool>((ref) => false);
final authManagerProvider = Provider<AuthManager>((ref) => AuthManager());
final selectedIndexProvider = StateProvider<int>((ref) => 0);

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthorized = ref.watch(authStateProvider);

    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ru', 'RU'),
      ],
      locale: const Locale('ru', 'RU'),
      home: isAuthorized ? const Home() : const StartScreen(),
      navigatorObservers: [MyNavigatorObserver()],
    );
  }
}

class Home extends ConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPageIndex = ref.watch(selectedIndexProvider);

    List<Widget> screens = [
      ServicesPage(),
      const SearchPage(),
      const CalendarPage(),
      const NoticePage(),
      const ProfileContent(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedPageIndex,
        children: screens,
      ),
      bottomNavigationBar: const NavBar(),
    );
  }
}
