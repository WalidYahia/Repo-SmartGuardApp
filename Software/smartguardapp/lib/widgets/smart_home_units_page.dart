import 'package:flutter/material.dart';
import 'package:smartguardapp/models/sensor_dto_mini.dart';
import 'dart:async';
import '../services/unified_smart_home_service.dart';
import '../widgets/unit_list_item.dart';

class SmartHomeUnitsPage extends StatefulWidget {
  final UnifiedSmartHomeService connectionService;

  const SmartHomeUnitsPage({super.key, required this.connectionService});

  @override
  State<SmartHomeUnitsPage> createState() => _SmartHomeUnitsPageState();
}

class _SmartHomeUnitsPageState extends State<SmartHomeUnitsPage> {
  late final UnifiedSmartHomeService _service;
  List<SensorDTO_Mini> units = [];
  bool isLoading = true;
  String? errorMessage;
  StreamSubscription<List<SensorDTO_Mini>>? _devicesSubscription;
  String? _expandedUnitId;
  Timer? _refreshTimer;
  bool _isPolling = false;

  @override
  void initState() {
    super.initState();
    _service = widget.connectionService;
    _initialize();
  }

  Future<void> _initialize() async {
    // Subscribe to devices stream if using MQTT
    _devicesSubscription = _service.subscribeToDevicesStream((devices) {
      if (mounted) {
        setState(() {
          units = devices;
          isLoading = false;
          errorMessage = null;
        });
      }
    });

    // Load units
    loadUnits();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _pollUnits();
    });
  }

  Future<void> _pollUnits() async {
    if (!mounted) return;
    if (_isPolling) return;
    if (_service.selectedMode != ConnectionMode.http) return;
    _isPolling = true;
    try {
      final fetched = await _service.fetchUnits();
      if (mounted) {
        setState(() {
          units = fetched;
        });
      }
    } catch (_) {
      // ignore errors during polling
    } finally {
      _isPolling = false;
    }
  }

  Future<void> loadUnits() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedUnits = await _service.fetchUnits();
      setState(() {
        units = fetchedUnits;
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

  Future<void> toggleUnit(String sensorId, bool newState) async {
    try {
      final updatedSensor = await _service.toggleUnit(sensorId, newState);
      
      if (updatedSensor != null) {
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
          SnackBar(
            content: Text(_parseErrorMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> updateUnit(SensorDTO_Mini updatedUnit) async {
    // try {
    //   // TODO: Call API/MQTT to update unit settings
    //   // For now, just update locally
    //   setState(() {
    //     final index = units.indexWhere((u) => u.sensorId == updatedUnit.sensorId);
    //     if (index != -1) {
    //       units[index] = updatedUnit;
    //     }
    //   });
      
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text('Unit updated successfully'),
    //         backgroundColor: Colors.green,
    //       ),
    //     );
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text(_parseErrorMessage(e.toString())),
    //         backgroundColor: Colors.red,
    //       ),
    //     );
    //   }
    // }
  }

  @override
  void dispose() {
    _devicesSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
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
                style: const TextStyle(color: Colors.red, fontSize: 16),
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
            key: ValueKey(unit.sensorId), // ✅ Add this
            unit: unit,
            isExpanded: _expandedUnitId == unit.sensorId,
            onTap: () {
              setState(() {
                if (_expandedUnitId == unit.sensorId) {
                  _expandedUnitId = null; // Collapse if already expanded
                } else {
                  _expandedUnitId = unit.sensorId; // Expand this unit
                }
              });
            },
            onToggle: (newState) => toggleUnit(unit.sensorId, unit.isOn),
            onUpdate: updateUnit,
          );
        },
      ),
    );
  }
}