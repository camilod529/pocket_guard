import 'package:formz/formz.dart';

enum CategoryError { empty }

class GenericStringInput extends FormzInput<String, CategoryError> {
  const GenericStringInput.dirty([super.value = '']) : super.dirty();
  const GenericStringInput.pure() : super.pure('');

  @override
  CategoryError? validator(String value) {
    if (value.isEmpty) return CategoryError.empty;
    return null;
  }
}
