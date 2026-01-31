// lib/widgets/unit_list_item.dart

import 'package:flutter/material.dart';
import '../models/sensor_dto_mini.dart';
import 'package:intl/intl.dart';
import '../dialogs/edit_unit_dialog.dart';

class UnitListItem extends StatefulWidget {
  final SensorDTO_Mini unit;
  final bool isExpanded;
  final VoidCallback onTap;
  final Future<void> Function(bool) onToggle;
  final Future<void> Function(SensorDTO_Mini) onUpdate;

  const UnitListItem({
    Key? key,
    required this.unit,
    required this.isExpanded,
    required this.onTap,
    required this.onToggle,
    required this.onUpdate,
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

  void _showEditDialog() async {
    final result = await showDialog<SensorDTO_Mini>(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) => EditUnitDialog(unit: widget.unit),
    );

    if (result != null) {
      await widget.onUpdate(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: Column(
        children: [
          InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.unit.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueAccent
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last seen: ${formatLastSeen(widget.unit.lastSeen)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            //decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  isToggling
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Switch(
                          value: widget.unit.isOn,
                          activeThumbColor: Colors.blueAccent,
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
                  AnimatedRotation(
                    turns: widget.isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    // child: Icon(
                    //   Icons.expand_more,
                    //   color: Colors.grey[600],
                    // ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: widget.isExpanded
                ? Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(
                        top: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow(
                                    'Inching Mode',
                                    widget.unit.isInInchingMode ? 'On' : 'Off',
                                    widget.unit.isInInchingMode
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  if (widget.unit.isInInchingMode) ...[
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      'Inching Duration',
                                      '${(widget.unit.inchingModeWidthInMs / 1000).toStringAsFixed(1)} seconds',
                                      Colors.blue,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: _showEditDialog,
                              tooltip: 'Edit',
                              color: Colors.blueAccent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}