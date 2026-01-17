// lib/pages/scenarios_page.dart

import 'package:flutter/material.dart';
import '../widgets/app_footer.dart';

class ScenariosPage extends StatefulWidget {
  const ScenariosPage({Key? key}) : super(key: key);

  @override
  State<ScenariosPage> createState() => _ScenariosPageState();
}

class _ScenariosPageState extends State<ScenariosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scenarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Add new scenario
            },
            tooltip: 'Add Scenario',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Scenarios',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Coming soon...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )//,
          //const AppFooter(),
        ],
      ),
    );
  }
}