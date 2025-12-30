// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CategoryForm)
const categoryFormProvider = CategoryFormFamily._();

final class CategoryFormProvider
    extends $AsyncNotifierProvider<CategoryForm, CategoryFormState> {
  const CategoryFormProvider._({
    required CategoryFormFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'categoryFormProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryFormHash();

  @override
  String toString() {
    return r'categoryFormProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CategoryForm create() => CategoryForm();

  @override
  bool operator ==(Object other) {
    return other is CategoryFormProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryFormHash() => r'a4dbe3f1cfbef89bcb3d360b735adefba6c74d40';

final class CategoryFormFamily extends $Family
    with
        $ClassFamilyOverride<
          CategoryForm,
          AsyncValue<CategoryFormState>,
          CategoryFormState,
          FutureOr<CategoryFormState>,
          String
        > {
  const CategoryFormFamily._()
    : super(
        retry: null,
        name: r'categoryFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoryFormProvider call(String categoryId) =>
      CategoryFormProvider._(argument: categoryId, from: this);

  @override
  String toString() => r'categoryFormProvider';
}

abstract class _$CategoryForm extends $AsyncNotifier<CategoryFormState> {
  late final _$args = ref.$arg as String;
  String get categoryId => _$args;

  FutureOr<CategoryFormState> build(String categoryId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<AsyncValue<CategoryFormState>, CategoryFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CategoryFormState>, CategoryFormState>,
              AsyncValue<CategoryFormState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
