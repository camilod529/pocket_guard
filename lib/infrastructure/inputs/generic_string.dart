import 'package:formz/formz.dart';

class GenericStringInput extends FormzInput<String, StringInputError> {
  const GenericStringInput.dirty([super.value = '']) : super.dirty();
  const GenericStringInput.pure() : super.pure('');

  @override
  StringInputError? validator(String value) {
    if (value.isEmpty) return StringInputError.empty;
    return null;
  }
}

enum StringInputError { empty }
