// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AccountFormNotifier)
const accountFormProvider = AccountFormNotifierProvider._();

final class AccountFormNotifierProvider
    extends $NotifierProvider<AccountFormNotifier, AccountFormState> {
  const AccountFormNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountFormNotifierHash();

  @$internal
  @override
  AccountFormNotifier create() => AccountFormNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountFormState>(value),
    );
  }
}

String _$accountFormNotifierHash() =>
    r'f919f4cc4192348e7cea5eae5d5a5ec665d54008';

abstract class _$AccountFormNotifier extends $Notifier<AccountFormState> {
  AccountFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AccountFormState, AccountFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AccountFormState, AccountFormState>,
              AccountFormState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
