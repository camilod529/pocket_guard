// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AccountForm)
const accountFormProvider = AccountFormFamily._();

final class AccountFormProvider
    extends $AsyncNotifierProvider<AccountForm, AccountFormState> {
  const AccountFormProvider._({
    required AccountFormFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountFormProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountFormHash();

  @override
  String toString() {
    return r'accountFormProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AccountForm create() => AccountForm();

  @override
  bool operator ==(Object other) {
    return other is AccountFormProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountFormHash() => r'88a81b695691a1583519858d3fe2421d86f3b3ea';

final class AccountFormFamily extends $Family
    with
        $ClassFamilyOverride<
          AccountForm,
          AsyncValue<AccountFormState>,
          AccountFormState,
          FutureOr<AccountFormState>,
          String
        > {
  const AccountFormFamily._()
    : super(
        retry: null,
        name: r'accountFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountFormProvider call(String accountId) =>
      AccountFormProvider._(argument: accountId, from: this);

  @override
  String toString() => r'accountFormProvider';
}

abstract class _$AccountForm extends $AsyncNotifier<AccountFormState> {
  late final _$args = ref.$arg as String;
  String get accountId => _$args;

  FutureOr<AccountFormState> build(String accountId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<AsyncValue<AccountFormState>, AccountFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AccountFormState>, AccountFormState>,
              AsyncValue<AccountFormState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
