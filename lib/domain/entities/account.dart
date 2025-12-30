import 'package:pocket_guard/utils/constants/global_constants.dart';

class AccountEntity {
  final String id;
  final String name;
  final String currency;
  final double balance;
  final AccountType type;
  final int sortOrder;

  AccountEntity({
    required this.id,
    required this.name,
    required this.currency,
    required this.balance,
    required this.type,
    required this.sortOrder,
  });

  factory AccountEntity.empty() {
    return AccountEntity(
      id: GlobalConstants.createId,
      name: '',
      currency: '',
      balance: 0.0,
      type: AccountType.asset,
      sortOrder: 0,
    );
  }

  AccountEntity copyWith({
    String? id,
    String? name,
    String? currency,
    double? balance,
    AccountType? type,
    int? sortOrder,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      type: type ?? this.type,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

enum AccountType { cash, asset, credit }
