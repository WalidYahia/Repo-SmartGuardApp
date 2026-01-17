// lib/dialogs/edit_unit_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/sensor_dto_mini.dart';
import '../services/unified_smart_home_service.dart';

class EditUnitDialog extends StatefulWidget {
  final SensorDTO_Mini unit;

  const EditUnitDialog({Key? key, required this.unit}) : super(key: key);

  @override
  State<EditUnitDialog> createState() => _EditUnitDialogState();
}

class _EditUnitDialogState extends State<EditUnitDialog> {
  late TextEditingController _nameController;
  late TextEditingController _durationController;
  late bool _isInInchingMode;
  final _nameFormKey = GlobalKey<FormState>();
  final _inchingFormKey = GlobalKey<FormState>();
  final UnifiedSmartHomeService _service = UnifiedSmartHomeService();
  
  bool _isSavingName = false;
  bool _isSavingInching = false;
  bool _nameSaved = false;
  bool _inchingSaved = false;

  int _inchingDurationSec = 1; // integer only
  static const int _minInching = 1;
  static const int _maxInching = 300; // adjust if needed

@override
void initState() {
  super.initState();
  _nameController = TextEditingController(text: widget.unit.name);
  _isInInchingMode = widget.unit.isInInchingMode;

  // Initialize _durationSeconds as an integer (seconds)
  _inchingDurationSec = (widget.unit.inchingModeWidthInMs / 1000).round();
}

@override
void dispose() {
  _nameController.dispose();
  super.dispose();
}

  void _saveName() async {
    if (_nameFormKey.currentState!.validate()) {
      setState(() {
        _isSavingName = true;
        _nameSaved = false;
      });
      
      try {
        final newName = _nameController.text.trim();
        
        // Call service to update name via API/MQTT
        await _service.updateUnitName(
          sensorId: widget.unit.sensorId,
          name: newName,
        );
        
        if (mounted) {
          setState(() {
            _nameSaved = true;
          });
          
          // Hide checkmark after 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _nameSaved = false;
              });
            }
          });
        }
      } catch (e) {
        if (mounted) {
          // Show error in dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to update name: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSavingName = false);
        }
      }
    }
  }

  Future<void> _saveInchingMode() async {
  setState(() {
    _isSavingInching = true;
    _inchingSaved = false;
  });

  try {
    if (_isInInchingMode) {
      // Turn inching mode ON
      final durationInMs = _inchingDurationSec * 1000;

      await _service.enableInchingMode(
        sensorId: widget.unit.sensorId,
        unitId: widget.unit.unitId,
        inchingTimeInMs: durationInMs,
      );
    } else {
      // Turn inching mode OFF
      await _service.disableInchingMode(
        sensorId: widget.unit.sensorId,
        unitId: widget.unit.unitId,
      );
    }

    if (!mounted) return;

    setState(() {
      _inchingSaved = true;
    });

    // Hide checkmark after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _inchingSaved = false;
        });
      }
    });
  } catch (e) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text('Failed to update inching mode: $e'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isSavingInching = false;
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.unit.name,
        style: const TextStyle(fontSize: 16, color: Colors.blueAccent),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Section
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _nameFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Device Name',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          labelStyle: TextStyle(fontSize: 13),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.label, size: 18),
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_nameSaved)
                              const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ),
                            ElevatedButton.icon(
                              onPressed: _isSavingName ? null : _saveName,
                              icon: _isSavingName 
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.save, size: 14),
                              label: Text(_isSavingName ? 'Saving...' : 'Save', 
                                         style: const TextStyle(fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                minimumSize: const Size(0, 32),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Inching Mode Section
          Card(
  elevation: 1,
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Form(
      key: _inchingFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inching Mode Settings',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),

          // 🔹 Mode Switch
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.timer, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Mode',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Switch(
                  value: _isInInchingMode,
                  activeThumbColor: Colors.blueAccent,
                  onChanged: (value) {
                    setState(() {
                      _isInInchingMode = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 Inching Controls
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isInInchingMode
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Duration label
                      const Text(
                        'Duration (seconds)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Up / Down control
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: _inchingDurationSec > 1
                                  ? () {
                                      setState(() {
                                        _inchingDurationSec--;
                                      });
                                    }
                                  : null,
                            ),
                            Text(
                              '$_inchingDurationSec',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                setState(() {
                                  _inchingDurationSec++;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          // 🔹 Save Button
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_inchingSaved)
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: _isSavingInching ? null : _saveInchingMode,
                  icon: _isSavingInching
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save, size: 14),
                  label: Text(
                    _isSavingInching ? 'Saving...' : 'Save',
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    minimumSize: const Size(0, 32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
)


          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close', style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}