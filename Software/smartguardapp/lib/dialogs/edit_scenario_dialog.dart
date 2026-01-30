// lib/dialogs/edit_scenario_dialog.dart

import 'package:flutter/material.dart';
import '../models/user_scenario.dart';

class EditScenarioDialog extends StatefulWidget {
  final UserScenario scenario;

  const EditScenarioDialog({Key? key, required this.scenario}) : super(key: key);

  @override
  State<EditScenarioDialog> createState() => _EditScenarioDialogState();
}

class _EditScenarioDialogState extends State<EditScenarioDialog> {
  late TextEditingController _nameController;
  late bool _isEnabled;
  late SwitchOutletStatus _action;
  late ScenarioLogic _logic;
  
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.scenario.name);
    _isEnabled = widget.scenario.isEnabled;
    _action = widget.scenario.action;
    _logic = widget.scenario.logicOfConditions;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      // Create updated scenario
      final updatedScenario = widget.scenario.copyWith(
        name: _nameController.text.trim(),
        isEnabled: _isEnabled,
        action: _action,
        logicOfConditions: _logic,
      );

      Navigator.of(context).pop(updatedScenario);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.scenario.name,
        style: const TextStyle(fontSize: 16, color: Colors.blueAccent),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Scenario Name',
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
              const SizedBox(height: 16),

              // Enabled Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.power_settings_new, color: Colors.blue, size: 18),
                        SizedBox(width: 8),
                        Text('Enabled', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: _isEnabled,
                        activeThumbColor: Colors.blueAccent,
                        onChanged: (value) {
                          setState(() {
                            _isEnabled = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action Dropdown
              DropdownButtonFormField<SwitchOutletStatus>(
                value: _action,
                decoration: const InputDecoration(
                  labelText: 'Action',
                  labelStyle: TextStyle(fontSize: 13),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flash_on, size: 18),
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  isDense: true,
                ),
                items: SwitchOutletStatus.values.map((action) {
                  return DropdownMenuItem(
                    value: action,
                    child: Text(
                      action == SwitchOutletStatus.on ? 'Turn On' : 'Turn Off',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _action = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Logic Dropdown
              DropdownButtonFormField<ScenarioLogic>(
                value: _logic,
                decoration: const InputDecoration(
                  labelText: 'Conditions Logic',
                  labelStyle: TextStyle(fontSize: 13),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.merge_type, size: 18),
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  isDense: true,
                ),
                items: ScenarioLogic.values.map((logic) {
                  return DropdownMenuItem(
                    value: logic,
                    child: Text(
                      logic == ScenarioLogic.and ? 'AND (All must match)' : 'OR (Any can match)',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _logic = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Conditions Summary (Read-only for now)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.rule, size: 18, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Conditions',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...widget.scenario.conditions.map((condition) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• ${_getConditionDescription(condition)}',
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(fontSize: 14)),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save', style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  String _getConditionDescription(UserScenarioCondition condition) {
    switch (condition.condition) {
      case ScenarioCondition.duration:
        return 'After ${condition.durationInSeconds} seconds';
      case ScenarioCondition.onTime:
        return 'At ${condition.time}';
      case ScenarioCondition.onOtherSensorValue:
        final sensorCount = condition.sensorsDependency?.length ?? 0;
        return 'When $sensorCount sensor(s) match conditions';
      default:
        return 'Unknown condition';
    }
  }
}