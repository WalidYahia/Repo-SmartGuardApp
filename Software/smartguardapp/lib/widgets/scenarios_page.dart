// lib/pages/scenarios_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import '../models/user_scenario.dart';
import '../dialogs/edit_scenario_dialog.dart';
import '../services/unified_smart_home_service.dart';

class ScenariosPage extends StatefulWidget {
    final UnifiedSmartHomeService connectionService;

 const ScenariosPage({Key? key, required this.connectionService}) : super(key: key);


  @override
  State<ScenariosPage> createState() => _ScenariosPageState();
}

class _ScenariosPageState extends State<ScenariosPage> {
  late final UnifiedSmartHomeService _service;
  List<UserScenario> userScenarios = [];
  bool isLoading = true;
  StreamSubscription<List<UserScenario>>? _devicesSubscription;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _service = widget.connectionService;
    _initialize();
  }


  Future<void> _initialize() async {
    // Subscribe to devices stream if using MQTT
    _devicesSubscription = _service.subscribeToUserScenario((scenarios) {
      if (mounted) {
        setState(() {
          userScenarios = scenarios;
          isLoading = false;
          errorMessage = null;
        });
      }
    });

    loadScenarios();
  }


  Future<void> loadScenarios() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedUnits = await _service.fetchScenarios();
      setState(() {
        userScenarios = fetchedUnits;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = _parseErrorMessage(e.toString());
        isLoading = false;
      });
    }
  }

    String _parseErrorMessage(String error) {
    if (error.contains('Could not connect to the server')) {
      return 'Could not connect to the server';
    } else if (error.contains('No response from the device')) {
      return 'No response from the device';
    } else if (error.contains('TimeoutException')) {
      return 'No response from the device';
    } else {
      return error.replaceAll('Exception: ', '');
    }
  }

  void _showEditDialog(UserScenario scenario) async {
    final result = await showDialog<UserScenario>(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditScenarioDialog(scenario: scenario),
    );

    if (result != null) {
      // TODO: Save scenario via API
      // await _apiService.updateScenario(result);
      
      setState(() {
        final index = userScenarios.indexWhere((s) => s.id == result.id);
        if (index != -1) {
          userScenarios[index] = result;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scenario updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error Loading Scenarios',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: loadScenarios,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (userScenarios.isEmpty) {
      return Center(
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
              'No Scenarios Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first automation scenario',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadScenarios,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: userScenarios.length,
        itemBuilder: (context, index) {
          final scenario = userScenarios[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Icon(
                Icons.auto_awesome,
                color: scenario.isEnabled ? Colors.green : Colors.grey,
                size: 32,
              ),
              title: Text(
                scenario.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  scenario.isEnabled ? 'Enabled' : 'Disabled',
                  style: TextStyle(
                    fontSize: 13,
                    color: scenario.isEnabled ? Colors.green : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _showEditDialog(scenario),
                tooltip: 'Edit',
                color: Colors.blueAccent,
              ),
            ),
          );
        },
      ),
    );
  }
}