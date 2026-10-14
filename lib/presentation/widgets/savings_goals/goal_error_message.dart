import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';

/// Explains *why* a savings goal operation was rejected, falling back to
/// the generic database message for anything that isn't a rule violation.
String goalErrorMessage(AppLocalizations l10n, Object error) {
  if (error is! SavingsGoalValidationException) {
    return l10n.error_db_operation_failed;
  }
  return switch (error.reason) {
    SavingsGoalError.currencyMismatch => l10n.goalErrorCurrencyMismatch,
    SavingsGoalError.insufficientAccountBalance =>
      l10n.goalErrorInsufficientAccountBalance,
    SavingsGoalError.insufficientGoalBalance =>
      l10n.goalErrorInsufficientGoalBalance,
    SavingsGoalError.accountMissing => l10n.goalErrorAccountMissing,
    SavingsGoalError.refundAccountRequired =>
      l10n.goalErrorRefundAccountRequired,
    SavingsGoalError.zeroAmount => l10n.goalAmountError,
    SavingsGoalError.currencyLocked => l10n.goalErrorCurrencyLocked,
  };
}
