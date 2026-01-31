// lib/dialogs/add_scenario_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/user_scenario.dart';
import '../models/sensor_dto_mini.dart';
import '../services/unified_smart_home_service.dart';

class AddScenarioDialog extends StatefulWidget {
  final UnifiedSmartHomeService service;
  /// When non-null, dialog is in edit mode: title shows scenario name, form is pre-filled, save returns updated scenario with same id.
  final UserScenario? scenario;

  const AddScenarioDialog({super.key, required this.service, this.scenario});

  @override
  State<AddScenarioDialog> createState() => _AddScenarioDialogState();
}

/// Border color matching the Switch/toggle (blueAccent).
const _kBorderColor = Colors.blueAccent;

class _AddScenarioDialogState extends State<AddScenarioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  List<SensorDTO_Mini> _availableSensors = [];
  String? _selectedTargetSensor;
  SwitchOutletStatus _action = SwitchOutletStatus.on;
  bool _isEnabled = true;
  ScenarioLogic _logic = ScenarioLogic.and;
  List<_ConditionBuilder> _conditions = [_ConditionBuilder()];
  
  bool _isLoading = true;
  bool _isSaving = false;
  bool _saveSuccess = false;
  String? _targetSensorError;
  Map<int, String> _conditionErrors = {}; 
  /// Keys: "${conditionIndex}_${sensorIndex}_sensor" | "${conditionIndex}_${sensorIndex}_value"
  Map<String, String> _sensorDepErrors = {}; 

  InputDecoration _decoration({
    String? labelText,
    String? hintText,
    String? errorText,
  }) =>
      InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        border: OutlineInputBorder(borderSide: BorderSide(color: _kBorderColor)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: _kBorderColor)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _kBorderColor, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        isDense: true,
      );

  @override
  void initState() {
    super.initState();
    _loadSensors();
  }

  Future<void> _loadSensors() async {
    try {
      final sensors = await widget.service.fetchUnits();
      setState(() {
        _availableSensors = sensors;
        _isLoading = false;
        if (widget.scenario != null) {
          final s = widget.scenario!;
          _nameController.text = s.name;
          _selectedTargetSensor = s.targetSensorId;
          _action = s.action;
          _isEnabled = s.isEnabled;
          _logic = s.logicOfConditions;
          _conditions = s.conditions.isEmpty
              ? [_ConditionBuilder()]
              : s.conditions.map((c) => _ConditionBuilder.from(c)).toList();

          // If editing and action is "On", convert any Duration conditions (Duration isn't allowed for "On")
          if (_action == SwitchOutletStatus.on) {
            for (final cb in _conditions) {
              if (cb.type == ScenarioCondition.duration) {
                cb.type = ScenarioCondition.onOtherSensorValue;
              }
            }
          }
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() async {
    _targetSensorError = null;
    _conditionErrors = {};
    _sensorDepErrors = {};

    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {});
      return;
    }

    if (_selectedTargetSensor == null) {
      setState(() => _targetSensorError = 'Please select a target sensor');
      return;
    }

    for (var i = 0; i < _conditions.length; i++) {
      final cb = _conditions[i];
      if (cb.type == null) {
        _conditionErrors[i] = 'Select a condition type';
        continue;
      }
      if (cb.type == ScenarioCondition.duration) {
        if (cb.duration == null || cb.duration! <= 0) {
          _conditionErrors[i] = 'Enter duration (e.g. 1 second)';
        }
      } else if (cb.type == ScenarioCondition.onTime) {
        if (cb.time == null || cb.time!.trim().isEmpty) {
          _conditionErrors[i] = 'Select a time';
        }
      } else if (cb.type == ScenarioCondition.onOtherSensorValue) {
        for (var j = 0; j < cb.sensors.length; j++) {
          final sb = cb.sensors[j];
          final keyS = '${i}_${j}_sensor';
          final keyV = '${i}_${j}_value';
          if (sb.sensorId == null || sb.sensorId!.isEmpty) {
            _sensorDepErrors[keyS] = 'Select a sensor';
          }
          if (_isSwitchType(sb.sensorType)) {
            // On/Off: "1" or "0" is valid
          } else {
            if (sb.value.trim().isEmpty) {
              _sensorDepErrors[keyV] = 'Enter a value';
            }
          }
        }
      }
    }
    if (_conditionErrors.isNotEmpty || _sensorDepErrors.isNotEmpty) {
      setState(() {});
      return;
    }

    setState(() {
      _isSaving = true;
      _saveSuccess = false;
    });

    final conditions = _conditions.map((cb) => cb.build()).where((c) => c != null).cast<UserScenarioCondition>().toList();

    final scenarioId = widget.scenario?.id ?? Uuid().v4();
    final scenario = UserScenario(
      id: scenarioId,
      name: _nameController.text.trim(),
      isEnabled: _isEnabled,
      targetSensorId: _selectedTargetSensor!,
      action: _action,
      logicOfConditions: _logic,
      conditions: conditions,
    );

    try {
      UserScenario? saved;
      if (widget.scenario == null) {
        saved = await widget.service.addScenario(scenario);
      } else {
        saved = await widget.service.updateScenario(scenario);
      }

      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _saveSuccess = true;
      });

      // Show check and close after a short delay
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        Navigator.of(context).pop(saved ?? scenario);
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to save scenario: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AlertDialog(
        content: SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final titleText = widget.scenario != null ? widget.scenario!.name : 'Add Scenario';
    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(
              titleText,
              style: const TextStyle(fontSize: 16, color: Colors.blueAccent),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Switch(
            value: _isEnabled,
            onChanged: (v) => setState(() => _isEnabled = v),
            activeThumbColor: Colors.blueAccent,
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [ 
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: _decoration(labelText: 'Name'),
                  validator: (v) => v?.trim().isEmpty ?? true ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                
                DropdownButtonFormField<String>(
                  initialValue: _selectedTargetSensor,
                  decoration: _decoration(
                    labelText: 'Target Sensor',
                    errorText: _targetSensorError,
                  ),
                  items: _availableSensors.map((s) => DropdownMenuItem(
                    value: s.sensorId,
                    child: Text(s.name, overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (v) => setState(() {
                    _selectedTargetSensor = v;
                    _targetSensorError = null;
                    // If user selects this sensor as target, clear it from any "On Sensor Value" condition
                    if (v != null) {
                      for (final cb in _conditions) {
                        if (cb.type == ScenarioCondition.onOtherSensorValue) {
                          for (final sb in cb.sensors) {
                            if (sb.sensorId == v) {
                              sb.sensorId = null;
                              sb.sensorType = null;
                            }
                          }
                        }
                      }
                    }
                  }),
                ),
                const SizedBox(height: 12),
                
                // Action (On/Off)
                DropdownButtonFormField<SwitchOutletStatus>(
                  initialValue: _action,
                  decoration: _decoration(labelText: 'Action'),
                  items: SwitchOutletStatus.values
                      .map((a) => DropdownMenuItem(
                            value: a,
                            child: Text(
                              a == SwitchOutletStatus.on ? 'Turn On' : 'Turn Off',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _action = v!;
                    // When action is "On", Duration should not be available — clear those selections (set to no selection)
                    if (_action == SwitchOutletStatus.on) {
                      for (final cb in _conditions) {
                        if (cb.type == ScenarioCondition.duration) {
                          cb.type = null;
                        }
                      }
                    }
                  }),
                ),
                const SizedBox(height: 12),
                
                DropdownButtonFormField<ScenarioLogic>(
                  initialValue: _logic,
                  decoration: _decoration(labelText: 'Conditions Logic'),
                  items: ScenarioLogic.values.map((l) => DropdownMenuItem(
                    value: l,
                    child: Text(l == ScenarioLogic.and ? 'AND (All)' : 'OR (Any)'),
                  )).toList(),
                  onChanged: (v) => setState(() => _logic = v!),
                ),
                const SizedBox(height: 16),
                
                const Divider(),
                const Text('Conditions', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                
                ..._conditions.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final cb = entry.value;
                  return _buildCondition(idx, cb);
                }),
                
                TextButton.icon(
                  onPressed: () => setState(() => _conditions.add(_ConditionBuilder())),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Condition'),
                  style: TextButton.styleFrom(foregroundColor: _kBorderColor),
                 ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_saveSuccess)
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(Icons.check_circle, color: Colors.green, size: 20),
              ),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(0, 32),
              ),
              child: _isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save'),
             ),
          ],
        ),
      ],
    );
  }

  Widget _buildCondition(int index, _ConditionBuilder cb) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Condition ${index + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (_conditions.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    tooltip: 'Remove condition',
                    onPressed: () => setState(() => _conditions.removeAt(index)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ScenarioCondition?>(
              initialValue: cb.type,
              decoration: _decoration(
                labelText: 'Condition type',
                errorText: _conditionErrors[index],
              ),
              hint: const Text('Select type'),
              items: ScenarioCondition.values
                  .where((t) => !(_action == SwitchOutletStatus.on && t == ScenarioCondition.duration))
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(_conditionName(t)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => cb.type = v),
            ),
            const SizedBox(height: 8),
            if (cb.type == ScenarioCondition.duration) ...[
              TextFormField(
                key: ValueKey('duration_$index'),
                initialValue: cb.duration?.toString() ?? '',
                decoration: _decoration(
                  labelText: 'Duration (seconds)',
                  errorText: cb.type == ScenarioCondition.duration
                      ? _conditionErrors[index]
                      : null,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) {
                  cb.duration = int.tryParse(v) ?? 0;
                  setState(() => _conditionErrors.remove(index));
                },
              ),
            ] else if (cb.type == ScenarioCondition.onTime) ...[
              InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      cb.time = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
                      _conditionErrors.remove(index);
                    });
                  }
                },
                child: InputDecorator(
                  decoration: _decoration(
                    labelText: 'Time',
                    errorText: cb.type == ScenarioCondition.onTime
                        ? _conditionErrors[index]
                        : null,
                  ),
                  child: Text(cb.time ?? 'Select time'),
                ),
              ),
            ] else if (cb.type == ScenarioCondition.onOtherSensorValue) ...[
              ...cb.sensors.asMap().entries.map((e) {
                final sidx = e.key;
                final sb = e.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Line 1: sensor dropdown (full width)
                        DropdownButtonFormField<String>(
                          initialValue: sb.sensorId,
                          decoration: _decoration(
                            labelText: 'Sensor',
                            errorText: _sensorDepErrors['${index}_${sidx}_sensor'],
                          ),
                          items: _availableSensors
                              .where((s) => s.sensorId != _selectedTargetSensor)
                              .map((s) => DropdownMenuItem(
                                    value: s.sensorId,
                                    child: Text(s.name, overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() {
                            sb.sensorId = v;
                            _sensorDepErrors.remove('${index}_${sidx}_sensor');
                            _sensorDepErrors.remove('${index}_${sidx}_value');
                            if (v != null) {
                              final selectedSensor = _availableSensors.firstWhere(
                                (s) => s.sensorId == v,
                                orElse: () => _availableSensors.first,
                              );
                              sb.sensorType = UnitType.fromInt(selectedSensor.type);
                              if (_isSwitchType(sb.sensorType) &&
                                  sb.value != '0' &&
                                  sb.value != '1') {
                                sb.value = '1';
                              }
                            } else {
                              sb.sensorType = null;
                            }
                          }),
                        ),
                        const SizedBox(height: 8),
                        // Line 2: operator + value + delete on same line
                        Row(
                          children: [
                            SizedBox(
                              width: 73,
                              child: DropdownButtonFormField<ScenarioOperator>(
                                initialValue: sb.operator,
                                decoration: _decoration(),
                                items: ScenarioOperator.values
                                    .map((o) => DropdownMenuItem(
                                          value: o,
                                          child: Text(_operatorSymbol(o)),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() => sb.operator = v!),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _isSwitchType(sb.sensorType)
                                  ? DropdownButtonFormField<String>(
                                      initialValue: sb.value == '0' ? '0' : '1',
                                      decoration: _decoration(labelText: 'Value', errorText: _sensorDepErrors['${index}_${sidx}_value']),
                                      items: const [
                                        DropdownMenuItem(value: '1', child: Text('On')),
                                        DropdownMenuItem(value: '0', child: Text('Off')),
                                      ],
                                      onChanged: (v) => setState(() => sb.value = v ?? '1'),
                                    )
                                  : TextFormField(
                                      key: ValueKey('sensor_value_${index}_$sidx'),
                                      initialValue: sb.value,
                                      decoration: _decoration(
                                        hintText: 'Value',
                                        errorText: _sensorDepErrors['${index}_${sidx}_value'],
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      onChanged: (v) {
                                        sb.value = v;
                                        setState(() => _sensorDepErrors.remove('${index}_${sidx}_value'));
                                      },
                                    ),
                            ),
                            if (cb.sensors.length > 1) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red, size: 18),
                                onPressed: () => setState(() => cb.sensors.removeAt(sidx)),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              TextButton.icon(
                onPressed: () => setState(() => cb.sensors.add(_SensorBuilder())),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Sensor', style: TextStyle(fontSize: 12)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _conditionName(ScenarioCondition c) {
    switch (c) {
      case ScenarioCondition.duration: return 'Duration';
      case ScenarioCondition.onTime: return 'On Time';
      case ScenarioCondition.onOtherSensorValue: return 'On Sensor Value';
    }
  }

  String _operatorSymbol(ScenarioOperator o) {
    switch (o) {
      case ScenarioOperator.equals: return '=';
      case ScenarioOperator.notEquals: return '≠';
      case ScenarioOperator.greaterThan: return '>';
      case ScenarioOperator.lessThan: return '<';
      case ScenarioOperator.greaterOrEqual: return '≥';
      case ScenarioOperator.lessOrEqual: return '≤';
    }
  }

  bool _isSwitchType(UnitType? t) =>
      t == UnitType.sonoffMiniR3 || t == UnitType.sonoffMiniR4M;
}

class _ConditionBuilder {
  // null = not selected
  ScenarioCondition? type;
  int? duration;
  String? time;
  List<_SensorBuilder> sensors = [_SensorBuilder()];

  static _ConditionBuilder from(UserScenarioCondition c) {
    final cb = _ConditionBuilder();
    cb.type = c.condition;
    cb.duration = c.durationInSeconds;
    cb.time = c.time;
    cb.sensors = c.sensorsDependency
            ?.map((s) => _SensorBuilder.from(s))
            .toList() ??
        [_SensorBuilder()];
    return cb;
  }

  UserScenarioCondition? build() {
    if (type == null) return null;
    if (type == ScenarioCondition.duration && (duration == null || duration! <= 0)) return null;
    if (type == ScenarioCondition.onTime && (time == null || time!.isEmpty)) return null;
    if (type == ScenarioCondition.onOtherSensorValue && sensors.where((s) => s.sensorId != null).isEmpty) return null;

    return UserScenarioCondition(
      condition: type!,
      durationInSeconds: duration ?? 0,
      time: time ?? '00:00:00',
      sensorsDependency: type == ScenarioCondition.onOtherSensorValue
          ? sensors.where((s) => s.sensorId != null).map((s) => s.build()).toList()
          : null,
    );
  }
}

class _SensorBuilder {
  String? sensorId;
  UnitType? sensorType;
  ScenarioOperator operator = ScenarioOperator.equals;
  String value = '1';

  static _SensorBuilder from(UserScenarioSensor s) {
    final sb = _SensorBuilder();
    sb.sensorId = s.sensorId;
    sb.sensorType = s.sensorType;
    sb.operator = s.operator;
    sb.value = s.value;
    return sb;
  }

  UserScenarioSensor build() {
    return UserScenarioSensor(
      sensorId: sensorId!,
      sensorType: sensorType ?? UnitType.unknown,
      value: value,
      operator: operator,
    );
  }
}