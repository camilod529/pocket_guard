import 'package:formz/formz.dart';

enum GoalAmountError { zeroOrNegative }

/// Used for both a goal's target and a single deposit/withdrawal amount -
/// the sign of a contribution comes from which action the user picked, so
/// the entered amount itself is always positive.
class GoalAmount extends FormzInput<double, GoalAmountError> {
  const GoalAmount.dirty([super.value = 0]) : super.dirty();
  const GoalAmount.pure() : super.pure(0);

  @override
  GoalAmountError? validator(double value) {
    if (value <= 0) return GoalAmountError.zeroOrNegative;
    return null;
  }
}
