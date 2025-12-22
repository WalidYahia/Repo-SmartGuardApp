// lib/pages/smart_home_units_page.dart

import 'package:flutter/material.dart';
import '../models/sensor_dto.dart';
import '../services/smart_home_api_service.dart';
import '../widgets/unit_list_item.dart';

class SmartHomeUnitsPage extends StatefulWidget {
  const SmartHomeUnitsPage({Key? key}) : super(key: key);

  @override
  State<SmartHomeUnitsPage> createState() => _SmartHomeUnitsPageState();
}

class _SmartHomeUnitsPageState extends State<SmartHomeUnitsPage> {
  final SmartHomeApiService _apiService = SmartHomeApiService();
  List<SensorDTO> units = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadUnits();
  }

  Future<void> loadUnits() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedUnits = await _apiService.fetchUnits();
      setState(() {
        units = fetchedUnits;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> toggleUnit(String sensorId, bool currentState) async {
  try {
    final updatedSensor = await _apiService.toggleUnit(sensorId, currentState);
    
    if (updatedSensor != null) {
      // Update the specific unit in the list without reloading everything
      setState(() {
        final index = units.indexWhere((u) => u.sensorId == sensorId);
        if (index != -1) {
          units[index] = updatedSensor;
        }
      });
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Units', 
        style: TextStyle(
        color: Colors.blueAccent,
        fontWeight: FontWeight.w600,
      ),),
        
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadUnits,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: loadUnits,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (units.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.devices_other, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No units found', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadUnits,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: units.length,
        itemBuilder: (context, index) {
          final unit = units[index];
          return UnitListItem(
            unit: unit,
            onToggle: (newState) => toggleUnit(unit.sensorId, unit.isOn),
          );
        },
      ),
    );
  }
}