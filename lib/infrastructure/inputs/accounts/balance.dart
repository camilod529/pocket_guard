import 'package:formz/formz.dart';

enum AccountBalanceError { none }

class AccountBalanceInput extends FormzInput<double, AccountBalanceError> {
  const AccountBalanceInput.dirty([super.value = 0.0]) : super.dirty();

  const AccountBalanceInput.pure([super.value = 0.0]) : super.pure();

  @override
  AccountBalanceError? validator(double value) {
    return null;
  }
}
