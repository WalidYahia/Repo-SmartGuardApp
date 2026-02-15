// lib/pages/scenarios_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_scenario.dart';
import '../dialogs/edit_scenario_dialog.dart';
import '../dialogs/add_scenario_dialog.dart';
import '../services/unified_smart_home_service.dart';

class ScenariosPage extends StatefulWidget {
  final UnifiedSmartHomeService connectionService;

  const ScenariosPage({super.key, required this.connectionService});

  @override
  State<ScenariosPage> createState() => _ScenariosPageState();
}

class _ScenariosPageState extends State<ScenariosPage> {
  late final UnifiedSmartHomeService _service;
  List<UserScenario> userScenarios = [];
  bool isLoading = true;
  StreamSubscription<List<UserScenario>>? _scenariosSubscription;
  Timer? _refreshTimer;
  bool _isPolling = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _service = widget.connectionService;
    _initialize();
  }

  Future<void> _initialize() async {
    _scenariosSubscription = _service.subscribeToUserScenario((scenarios) {
      if (mounted) {
        setState(() {
          userScenarios = scenarios;
          isLoading = false;
          errorMessage = null;
        });
      }
    });

    loadScenarios();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _pollScenarios();
    });
  }

  Future<void> _pollScenarios() async {
    if (!mounted) return;
    if (_isPolling) return;
    if (_service.selectedMode != ConnectionMode.http) return;
    _isPolling = true;
    try {
      final fetched = await _service.fetchScenarios();
      if (mounted) {
        setState(() {
          userScenarios = fetched;
        });
      }
    } catch (_) {
      // ignore polling errors
    } finally {
      _isPolling = false;
    }
  }

  Future<void> loadScenarios() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedScenarios = await _service.fetchScenarios();
      if (mounted) {
        setState(() {
          userScenarios = fetchedScenarios;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = _parseErrorMessage(e.toString());
          isLoading = false;
        });
      }
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
      builder: (context) => EditScenarioDialog(
        scenario: scenario,
        service: _service,
      ),
    );

    if (result != null) {
      // Refresh list and show feedback
      await loadScenarios();
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

  void _showAddDialog() async {
    final result = await showDialog<UserScenario>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddScenarioDialog(service: _service),
    );

    if (result != null) {
      // Refresh list and show feedback
      await loadScenarios();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scenario created successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _confirmDelete(UserScenario scenario) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Scenario'),
        content: Text('Are you sure you want to delete "${scenario.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.deleteScenario(scenario.id);
        await loadScenarios(); 
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Scenario deleted successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: ${_parseErrorMessage(e.toString())}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _scenariosSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
            Icon(Icons.auto_awesome, size: 64, color: Colors.grey[400]),
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
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              leading: Icon(
                Icons.auto_awesome,
                color: scenario.isEnabled ? Colors.green : Colors.grey,
                size: 20,
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showEditDialog(scenario),
                    tooltip: 'Edit',
                    color: Colors.blueAccent,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () => _confirmDelete(scenario),
                    tooltip: 'Delete',
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}