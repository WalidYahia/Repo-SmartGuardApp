// lib/dialogs/add_user_dialog.dart

import 'package:flutter/material.dart';

class AddUserDialog extends StatelessWidget {
  const AddUserDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      title: Text('Add User'),
      content: Text('User management coming soon.'),
    );
  }
}
