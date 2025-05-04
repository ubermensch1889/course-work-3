import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:test/calendar/screens/calendar_screen.dart';
import 'package:test/main.dart';
import 'package:test/notifications/screens/notification_screen.dart';
import 'package:test/profile/screens/profile_screen.dart';
import 'package:test/search/screens/search_screen.dart';
import 'package:test/services/screens/services_screen.dart';

class NavBar extends ConsumerWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPageIndex = ref.watch(selectedIndexProvider);
    final isNavBarVisible = ref.watch(isNavBarVisibleProvider);

    final List<Widget> screens = [
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
      bottomNavigationBar: isNavBarVisible ? Container(
        height: 90,
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color.fromRGBO(22, 79, 148, 1), width: 1))
        ),
        child: BottomNavigationBar(
          iconSize: 30,
          type: BottomNavigationBarType.fixed,
          currentIndex: selectedPageIndex,
          onTap: (index) {
            ref.read(selectedIndexProvider.notifier).state = index;
          },
          selectedItemColor: const Color.fromARGB(255, 22, 79, 148),
          unselectedItemColor: const Color.fromARGB(255, 104, 117, 133),
          selectedLabelStyle:
              const TextStyle(fontFamily: 'CeraPro', fontSize: 14),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Сервисы',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Поиск',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.calendarCheck),
              label: 'Календарь',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.bell),
              label: 'Уведомления',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.user),
              label: 'Профиль',
            ),
          ],
        ),
      ) : null,
    );
  }
}
