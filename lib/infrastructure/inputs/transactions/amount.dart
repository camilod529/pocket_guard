import 'package:formz/formz.dart';

enum AmountError { empty, invalid, zeroOrNegative }

class TransactionAmount extends FormzInput<double, AmountError> {
  const TransactionAmount.dirty([super.value = 0]) : super.dirty();
  const TransactionAmount.pure() : super.pure(0);

  @override
  AmountError? validator(double value) {
    if (value.toString().isEmpty) return AmountError.empty;
    if (value <= 0) {
      return AmountError.zeroOrNegative;
    }
    return null;
  }
}
