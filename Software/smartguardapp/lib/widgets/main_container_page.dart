// lib/pages/main_container_page.dart

import 'package:flutter/material.dart';
import 'smart_home_units_page.dart';
import 'scenarios_page.dart';
import 'users_page.dart';
import 'app_footer.dart';

class MainContainerPage extends StatefulWidget {
  const MainContainerPage({Key? key}) : super(key: key);

  @override
  State<MainContainerPage> createState() => _MainContainerPageState();
}

class _MainContainerPageState extends State<MainContainerPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const SmartHomeUnitsPage(),
    const ScenariosPage(),
    const UsersPage(),
  ];

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: IndexedStack(
      index: _currentIndex,
      children: _pages,
    ),
    bottomNavigationBar: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.devices),
              label: 'Units',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome),
              label: 'Scenarios',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Users',
            ),
          ],
        ),
        const AppFooter(), // 👈 NOW BELOW TABS
      ],
    ),
  );
}
}