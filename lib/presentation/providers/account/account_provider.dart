import 'package:money_manager_flutter/domain/entities/account.dart';
import 'package:money_manager_flutter/presentation/providers/account/accounts_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_provider.g.dart';

@Riverpod(keepAlive: true)
class AccountNotifier extends _$AccountNotifier {
  @override
  Future<AccountEntity?> build(String id) async {
    final repository = ref.read(accountRepositoryProvider);
    final account = await repository.getAccountById(id);
    return account;
  }
}
