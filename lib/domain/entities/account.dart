class AccountEntity {
  final String id;
  final String name;
  final String currency;

  AccountEntity({required this.id, required this.name, required this.currency});

  factory AccountEntity.empty() {
    return AccountEntity(id: 'create', name: '', currency: '');
  }
}
