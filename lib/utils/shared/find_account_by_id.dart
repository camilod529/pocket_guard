import 'package:pocket_guard/domain/entities/account.dart';

/// Looks up the [AccountEntity] whose `id` matches [accountId] in [accounts].
///
/// Returns `null` when [accountId] is `null`, [accounts] is `null` (e.g. the
/// accounts provider hasn't loaded yet), or no account in the list matches -
/// callers should fall back to a default value with `??` instead of chaining
/// nullable field access. Unlike `List.firstWhere`, this never throws
/// [StateError] when nothing matches, which can otherwise happen when form
/// state still references an account id that was just deleted.
AccountEntity? findAccountById(List<AccountEntity>? accounts, String? accountId) {
  if (accountId == null || accounts == null) return null;

  for (final account in accounts) {
    if (account.id == accountId) return account;
  }

  return null;
}
