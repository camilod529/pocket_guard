import 'package:formz/formz.dart';

enum DescriptionError { empty, tooShort, tooLong }

class TransactionDescription extends FormzInput<String, DescriptionError> {
  const TransactionDescription.dirty([super.value = '']) : super.dirty();
  const TransactionDescription.pure() : super.pure('');

  @override
  DescriptionError? validator(String value) {
    if (value.isEmpty) return DescriptionError.empty;
    if (value.length < 2) return DescriptionError.tooShort;
    if (value.length > 200) return DescriptionError.tooLong;
    return null;
  }
}
