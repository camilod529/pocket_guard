import 'package:formz/formz.dart';

class AccountCurrency extends FormzInput<String, AccountCurrencyError> {
  static final _currencyRegExp = RegExp(r'^[A-Z]{3}$');
  const AccountCurrency.dirty([super.value = '']) : super.dirty();

  const AccountCurrency.pure([super.value = '']) : super.pure();

  @override
  AccountCurrencyError? validator(String value) {
    if (value.isEmpty) return AccountCurrencyError.empty;
    if (!_currencyRegExp.hasMatch(value)) return AccountCurrencyError.invalid;
    return null;
  }
}

enum AccountCurrencyError { empty, invalid }
