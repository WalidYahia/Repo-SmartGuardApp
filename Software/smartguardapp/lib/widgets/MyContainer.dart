import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smartguardapp/services/unified_smart_home_service.dart';
import 'smart_home_units_page.dart';
import 'scenarios_page.dart';
import 'users_page.dart';
import 'app_footer.dart';


class MasterPage extends StatefulWidget {
  const MasterPage({Key? key}) : super(key: key);

  @override
  State<MasterPage> createState() => _MasterPageState();
}

class _MasterPageState extends State<MasterPage> {

final UnifiedSmartHomeService _service = UnifiedSmartHomeService();
 
int _currentIndex = 0;

  final List<Widget> _pages = [
    const SmartHomeUnitsPage(),
    const ScenariosPage(),
    const UsersPage(),
  ];

    @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Initialize and determine connection mode once
    await _service.initialize();
  }

    @override
  void dispose() {
    super.dispose();
  }

@override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: _buildHeader(),
      body:  IndexedStack(
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

PreferredSizeWidget _buildHeader() {
    return AppBar(
        centerTitle: false,
        title: const Text('My Home', 
        style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),),
        actions: [
          // Connection status indicator
          if (_service.selectedMode != null)
            Padding(
              padding: const EdgeInsets.only(right: 22),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _service.selectedMode == ConnectionMode.http 
                        ? Colors.blue 
                        : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    
                    _service.selectedMode == ConnectionMode.http ? 'Local' : 'Remote',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
  }
}