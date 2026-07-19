import 'package:formz/formz.dart';

enum BudgetMonthlyLimitError { empty, invalid, zeroOrNegative }

class BudgetMonthlyLimit extends FormzInput<double, BudgetMonthlyLimitError> {
  const BudgetMonthlyLimit.dirty([super.value = 0]) : super.dirty();
  const BudgetMonthlyLimit.pure() : super.pure(0);

  @override
  BudgetMonthlyLimitError? validator(double value) {
    if (value.toString().isEmpty) return BudgetMonthlyLimitError.empty;
    if (value <= 0) {
      return BudgetMonthlyLimitError.zeroOrNegative;
    }
    return null;
  }
}
