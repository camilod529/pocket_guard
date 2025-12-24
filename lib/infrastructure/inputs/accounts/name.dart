import 'package:formz/formz.dart';

class AccountName extends FormzInput<String, AccountNameError> {
  static const _minLength = 2;
  static const _maxLength = 50;

  static final _nameRegExp = RegExp(r'^[a-zA-Z0-9\s\-_.]+$');
  const AccountName.dirty([super.value = '']) : super.dirty();
  const AccountName.pure([super.value = '']) : super.pure();

  @override
  AccountNameError? validator(String value) {
    if (value.isEmpty) return AccountNameError.empty;
    if (value.length < _minLength) return AccountNameError.tooShort;
    if (value.length > _maxLength) return AccountNameError.tooLong;
    if (!_nameRegExp.hasMatch(value)) return AccountNameError.invalidChars;
    return null;
  }
}

enum AccountNameError { empty, tooShort, tooLong, invalidChars }
