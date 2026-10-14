// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WishlistForm)
const wishlistFormProvider = WishlistFormFamily._();

final class WishlistFormProvider
    extends $AsyncNotifierProvider<WishlistForm, WishlistFormState> {
  const WishlistFormProvider._({
    required WishlistFormFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'wishlistFormProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$wishlistFormHash();

  @override
  String toString() {
    return r'wishlistFormProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  WishlistForm create() => WishlistForm();

  @override
  bool operator ==(Object other) {
    return other is WishlistFormProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$wishlistFormHash() => r'7cddf87acb68f082b2ee9727e2024682720d6add';

final class WishlistFormFamily extends $Family
    with
        $ClassFamilyOverride<
          WishlistForm,
          AsyncValue<WishlistFormState>,
          WishlistFormState,
          FutureOr<WishlistFormState>,
          String
        > {
  const WishlistFormFamily._()
    : super(
        retry: null,
        name: r'wishlistFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WishlistFormProvider call(String id) =>
      WishlistFormProvider._(argument: id, from: this);

  @override
  String toString() => r'wishlistFormProvider';
}

abstract class _$WishlistForm extends $AsyncNotifier<WishlistFormState> {
  late final _$args = ref.$arg as String;
  String get id => _$args;

  FutureOr<WishlistFormState> build(String id);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<AsyncValue<WishlistFormState>, WishlistFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<WishlistFormState>, WishlistFormState>,
              AsyncValue<WishlistFormState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
