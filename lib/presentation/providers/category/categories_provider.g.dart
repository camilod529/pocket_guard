// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(categoriesByType)
const categoriesByTypeProvider = CategoriesByTypeFamily._();

final class CategoriesByTypeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CategoryEntity>>,
          List<CategoryEntity>,
          FutureOr<List<CategoryEntity>>
        >
    with
        $FutureModifier<List<CategoryEntity>>,
        $FutureProvider<List<CategoryEntity>> {
  const CategoriesByTypeProvider._({
    required CategoriesByTypeFamily super.from,
    required TransactionType super.argument,
  }) : super(
         retry: null,
         name: r'categoriesByTypeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoriesByTypeHash();

  @override
  String toString() {
    return r'categoriesByTypeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CategoryEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CategoryEntity>> create(Ref ref) {
    final argument = this.argument as TransactionType;
    return categoriesByType(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoriesByTypeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoriesByTypeHash() => r'0fba3adb8843d445bf14c3bff51f1994625af93f';

final class CategoriesByTypeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<CategoryEntity>>,
          TransactionType
        > {
  const CategoriesByTypeFamily._()
    : super(
        retry: null,
        name: r'categoriesByTypeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoriesByTypeProvider call(TransactionType type) =>
      CategoriesByTypeProvider._(argument: type, from: this);

  @override
  String toString() => r'categoriesByTypeProvider';
}

@ProviderFor(categoryDataSource)
const categoryDataSourceProvider = CategoryDataSourceProvider._();

final class CategoryDataSourceProvider
    extends
        $FunctionalProvider<
          CategoryDataSource,
          CategoryDataSource,
          CategoryDataSource
        >
    with $Provider<CategoryDataSource> {
  const CategoryDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryDataSourceHash();

  @$internal
  @override
  $ProviderElement<CategoryDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CategoryDataSource create(Ref ref) {
    return categoryDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryDataSource>(value),
    );
  }
}

String _$categoryDataSourceHash() =>
    r'70faca90a47f36dd17306b8039bd305d03e80258';

@ProviderFor(categoryRepository)
const categoryRepositoryProvider = CategoryRepositoryProvider._();

final class CategoryRepositoryProvider
    extends
        $FunctionalProvider<
          CategoryRepository,
          CategoryRepository,
          CategoryRepository
        >
    with $Provider<CategoryRepository> {
  const CategoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<CategoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CategoryRepository create(Ref ref) {
    return categoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryRepository>(value),
    );
  }
}

String _$categoryRepositoryHash() =>
    r'a13a2ec7d6134dd9a09083472dee6495a9295c1d';

@ProviderFor(CategoriesNotifier)
const categoriesProvider = CategoriesNotifierProvider._();

final class CategoriesNotifierProvider
    extends $AsyncNotifierProvider<CategoriesNotifier, List<CategoryEntity>> {
  const CategoriesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesNotifierHash();

  @$internal
  @override
  CategoriesNotifier create() => CategoriesNotifier();
}

String _$categoriesNotifierHash() =>
    r'073638789e50b7fca93773cbc8218fce197ad4ad';

abstract class _$CategoriesNotifier
    extends $AsyncNotifier<List<CategoryEntity>> {
  FutureOr<List<CategoryEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<List<CategoryEntity>>, List<CategoryEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<CategoryEntity>>,
                List<CategoryEntity>
              >,
              AsyncValue<List<CategoryEntity>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(CategoryNotifier)
const categoryProvider = CategoryNotifierFamily._();

final class CategoryNotifierProvider
    extends $AsyncNotifierProvider<CategoryNotifier, CategoryEntity?> {
  const CategoryNotifierProvider._({
    required CategoryNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'categoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryNotifierHash();

  @override
  String toString() {
    return r'categoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CategoryNotifier create() => CategoryNotifier();

  @override
  bool operator ==(Object other) {
    return other is CategoryNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryNotifierHash() => r'de4ebc08dee3277821f3660c569d1e2c733ea405';

final class CategoryNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          CategoryNotifier,
          AsyncValue<CategoryEntity?>,
          CategoryEntity?,
          FutureOr<CategoryEntity?>,
          String
        > {
  const CategoryNotifierFamily._()
    : super(
        retry: null,
        name: r'categoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoryNotifierProvider call(String categoryId) =>
      CategoryNotifierProvider._(argument: categoryId, from: this);

  @override
  String toString() => r'categoryProvider';
}

abstract class _$CategoryNotifier extends $AsyncNotifier<CategoryEntity?> {
  late final _$args = ref.$arg as String;
  String get categoryId => _$args;

  FutureOr<CategoryEntity?> build(String categoryId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<CategoryEntity?>, CategoryEntity?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CategoryEntity?>, CategoryEntity?>,
              AsyncValue<CategoryEntity?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
