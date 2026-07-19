import 'package:formz/formz.dart';

enum RecurringTransactionAmountError { empty, invalid, zeroOrNegative }

class RecurringTransactionAmount
    extends FormzInput<double, RecurringTransactionAmountError> {
  const RecurringTransactionAmount.dirty([super.value = 0]) : super.dirty();
  const RecurringTransactionAmount.pure() : super.pure(0);

  @override
  RecurringTransactionAmountError? validator(double value) {
    if (value.toString().isEmpty) return RecurringTransactionAmountError.empty;
    if (value <= 0) {
      return RecurringTransactionAmountError.zeroOrNegative;
    }
    return null;
  }
}
