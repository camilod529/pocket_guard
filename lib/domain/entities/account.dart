import 'package:money_manager_flutter/utils/constants/global_constants.dart';

class AccountEntity {
  final String id;
  final String name;
  final String currency;

  AccountEntity({required this.id, required this.name, required this.currency});

  factory AccountEntity.empty() {
    return AccountEntity(id: GlobalConstants.createId, name: '', currency: '');
  }
}
