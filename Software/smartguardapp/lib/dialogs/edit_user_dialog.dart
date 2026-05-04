// lib/dialogs/edit_user_dialog.dart

import 'package:flutter/material.dart';

class EditUserDialog extends StatelessWidget {
  final Map<String, dynamic> user;

  const EditUserDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      title: Text('Edit User'),
      content: Text('User management coming soon.'),
    );
  }
}
