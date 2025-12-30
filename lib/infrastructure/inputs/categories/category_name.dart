import 'package:formz/formz.dart';

enum CategoryError { empty, tooShort, tooLong }

class CategoryNameInput extends FormzInput<String, CategoryError> {
  const CategoryNameInput.dirty([super.value = '']) : super.dirty();
  const CategoryNameInput.pure() : super.pure('');

  @override
  CategoryError? validator(String value) {
    if (value.isEmpty) return CategoryError.empty;
    if (value.length < 2) return CategoryError.tooShort;
    if (value.length > 50) return CategoryError.tooLong;
    return null;
  }
}
