import 'package:flutter/material.dart';

import '../../../config/color_config.dart';

Widget buildDetailItem(
    BuildContext context,
    String label,
    String? value, {
      bool isTitle = false,
      bool isMultiline = false,
      IconData? icon,
    }) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: ColorConfig.primary,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: isTitle ? 18 : 16,
              fontWeight: isTitle ? FontWeight.w600 : FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: Text(
          value ?? 'Không có',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
            height: isMultiline ? 1.4 : null,
          ),
          maxLines: isMultiline ? null : 1,
          overflow: isMultiline ? null : TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}