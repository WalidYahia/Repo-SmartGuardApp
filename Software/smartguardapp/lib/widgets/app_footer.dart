// lib/widgets/app_footer.dart

import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Beta Version, powered by ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          // You can use either an image asset or icon
          // Option 1: Using Image Asset
          Image.asset(
            'assets/images/Syncro.png',
            height: 16,
            width: 16,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to icon if image not found
              return Icon(
                Icons.business,
                size: 16,
                color: Colors.grey[600],
              );
            },
          ),
          const SizedBox(width: 4),
          Text(
            'Syncro-eg',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}