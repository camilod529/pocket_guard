// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(accountDataSource)
const accountDataSourceProvider = AccountDataSourceProvider._();

final class AccountDataSourceProvider
    extends
        $FunctionalProvider<
          AccountDataSource,
          AccountDataSource,
          AccountDataSource
        >
    with $Provider<AccountDataSource> {
  const AccountDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountDataSourceHash();

  @$internal
  @override
  $ProviderElement<AccountDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccountDataSource create(Ref ref) {
    return accountDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountDataSource>(value),
    );
  }
}

String _$accountDataSourceHash() => r'20e12bdcf44aed94216382659a22286c581c577e';

@ProviderFor(accountRepository)
const accountRepositoryProvider = AccountRepositoryProvider._();

final class AccountRepositoryProvider
    extends
        $FunctionalProvider<
          AccountRepository,
          AccountRepository,
          AccountRepository
        >
    with $Provider<AccountRepository> {
  const AccountRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountRepositoryHash();

  @$internal
  @override
  $ProviderElement<AccountRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccountRepository create(Ref ref) {
    return accountRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountRepository>(value),
    );
  }
}

String _$accountRepositoryHash() => r'ec57ab2266c5f1ba5a246a736f51e7f142cce7af';

@ProviderFor(AccountNotifier)
const accountProvider = AccountNotifierProvider._();

final class AccountNotifierProvider
    extends $AsyncNotifierProvider<AccountNotifier, List<AccountEntity>> {
  const AccountNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountNotifierHash();

  @$internal
  @override
  AccountNotifier create() => AccountNotifier();
}

String _$accountNotifierHash() => r'051d2d03f629bf3a301e1aaeea330d3b9de509fa';

abstract class _$AccountNotifier extends $AsyncNotifier<List<AccountEntity>> {
  FutureOr<List<AccountEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<AccountEntity>>, List<AccountEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AccountEntity>>, List<AccountEntity>>,
              AsyncValue<List<AccountEntity>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
