import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    // Split the localized question around the entity name (rather than
    // hardcoding English word order/quote style - French uses « », not "")
    // so the entity can still be bolded regardless of the translation.
    final question = l10n.deleteConfirmationQuestion(entity);
    final entityIndex = question.indexOf(entity);
    final questionSpans = entityIndex == -1
        ? [TextSpan(text: question)]
        : [
            TextSpan(text: question.substring(0, entityIndex)),
            TextSpan(
              text: entity,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            TextSpan(text: question.substring(entityIndex + entity.length)),
          ];

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
              children: questionSpans,
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
          child: Text(l10n.cancel),
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
          child: Text(l10n.deleteAction),
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
