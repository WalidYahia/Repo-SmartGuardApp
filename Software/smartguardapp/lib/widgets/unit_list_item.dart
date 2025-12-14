// lib/widgets/unit_list_item.dart

import 'package:flutter/material.dart';
import '../models/sensor_dto.dart';
import 'package:intl/intl.dart';

class UnitListItem extends StatefulWidget {
  final SensorDTO unit;
  final Future<void> Function(bool) onToggle;

  const UnitListItem({
    Key? key,
    required this.unit,
    required this.onToggle,
  }) : super(key: key);

  @override
  State<UnitListItem> createState() => _UnitListItemState();
}

class _UnitListItemState extends State<UnitListItem> {
  bool isToggling = false;

  String formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(lastSeen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          widget.unit.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Last seen: ${formatLastSeen(widget.unit.lastSeen)}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ),
        trailing: isToggling
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Switch(
                value: widget.unit.isOn,
                activeThumbColor: Colors.lightBlue,
                onChanged: (newState) async {
                  setState(() => isToggling = true);
                  try {
                    await widget.onToggle(newState);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to toggle: $e')),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() => isToggling = false);
                    }
                  }
                },
              ),
      ),
    );
  }
}