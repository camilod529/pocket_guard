import 'package:flutter/material.dart';
import 'package:pocket_guard/domain/entities/category.dart';

class TransactionIcons {
  static IconData getIconByType(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return Icons.arrow_upward;
      case TransactionType.income:
        return Icons.arrow_downward;
      case TransactionType.transfer:
        return Icons.swap_horiz;
    }
  }
}
