// lib/dialogs/edit_scenario_dialog.dart

import 'package:flutter/material.dart';
import '../models/user_scenario.dart';
import '../services/unified_smart_home_service.dart';
import 'add_scenario_dialog.dart';

/// Opens the same full form as [AddScenarioDialog] with scenario data pre-filled for editing.
/// Title shows scenario name with enabled toggle beside it (no label).
class EditScenarioDialog extends StatelessWidget {
  final UserScenario scenario;
  final UnifiedSmartHomeService service;

  const EditScenarioDialog({
    super.key,
    required this.scenario,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return AddScenarioDialog(
      service: service,
      scenario: scenario,
    );
  }
}
