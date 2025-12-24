import 'package:flutter/material.dart';
import 'package:money_manager_flutter/config/database/database.dart';
import 'package:money_manager_flutter/l10n/app_localizations.dart';

String getCategoryLabel(BuildContext context, Category category) {
  final l10n = AppLocalizations.of(context)!;

  if (category.origin == CategoryOrigin.system && category.nameKey != null) {
    switch (category.nameKey) {
      case 'category_income_salary':
        return l10n.category_income_salary;
      case 'category_income_freelance':
        return l10n.category_income_freelance;
      case 'category_expense_food_dining':
        return l10n.category_expense_food_dining;
      case 'category_expense_transportation':
        return l10n.category_expense_transportation;
      case 'category_expense_rent':
        return l10n.category_expense_rent;
      case 'category_transfer':
        return l10n.category_transfer;
      default:
        return category.label; // fallback
    }
  }

  // User categories: show as entered
  return category.label;
}
