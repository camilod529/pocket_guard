import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeleteConfirmationModal extends StatelessWidget {
  final String title;
  final String entity;
  final String? description;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const DeleteConfirmationModal({
    super.key,
    required this.title,
    required this.entity,
    this.description,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      icon: Icon(Icons.warning_rounded, color: colors.error, size: 48),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              children: [
                const TextSpan(text: 'Are you sure you want to delete '),
                TextSpan(
                  text: '"$entity"',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                const TextSpan(text: '?'),
              ],
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 12),
            Text(
              description!,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pop(false);
            onCancel?.call();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            context.pop(true);
            onConfirm();
          },
          style: FilledButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: colors.onError,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String entity,
    String? description,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationModal(
        title: title,
        entity: entity,
        description: description,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }
}
