// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AccountNotifier)
const accountProvider = AccountNotifierFamily._();

final class AccountNotifierProvider
    extends $AsyncNotifierProvider<AccountNotifier, AccountEntity?> {
  const AccountNotifierProvider._({
    required AccountNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountNotifierHash();

  @override
  String toString() {
    return r'accountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AccountNotifier create() => AccountNotifier();

  @override
  bool operator ==(Object other) {
    return other is AccountNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountNotifierHash() => r'f79a5cb2c18dc69417849beef55426485f904616';

final class AccountNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          AccountNotifier,
          AsyncValue<AccountEntity?>,
          AccountEntity?,
          FutureOr<AccountEntity?>,
          String
        > {
  const AccountNotifierFamily._()
    : super(
        retry: null,
        name: r'accountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  AccountNotifierProvider call(String id) =>
      AccountNotifierProvider._(argument: id, from: this);

  @override
  String toString() => r'accountProvider';
}

abstract class _$AccountNotifier extends $AsyncNotifier<AccountEntity?> {
  late final _$args = ref.$arg as String;
  String get id => _$args;

  FutureOr<AccountEntity?> build(String id);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<AccountEntity?>, AccountEntity?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AccountEntity?>, AccountEntity?>,
              AsyncValue<AccountEntity?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
