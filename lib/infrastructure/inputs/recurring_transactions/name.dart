import 'package:formz/formz.dart';

enum RecurringTransactionNameError { empty, tooShort, tooLong }

class RecurringTransactionName
    extends FormzInput<String, RecurringTransactionNameError> {
  const RecurringTransactionName.dirty([super.value = '']) : super.dirty();
  const RecurringTransactionName.pure() : super.pure('');

  @override
  RecurringTransactionNameError? validator(String value) {
    if (value.isEmpty) return RecurringTransactionNameError.empty;
    if (value.length < 2) return RecurringTransactionNameError.tooShort;
    if (value.length > 200) return RecurringTransactionNameError.tooLong;
    return null;
  }
}
