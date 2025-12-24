import 'package:formz/formz.dart';

enum AmountError { empty, invalid, zeroOrNegative }

class TransactionAmount extends FormzInput<String, AmountError> {
  const TransactionAmount.dirty([super.value = '']) : super.dirty();
  const TransactionAmount.pure() : super.pure('');

  @override
  AmountError? validator(String value) {
    if (value.isEmpty) return AmountError.empty;
    final doubleAmount = double.tryParse(value);
    if (doubleAmount == null || doubleAmount <= 0) {
      return AmountError.zeroOrNegative;
    }
    return null;
  }
}
