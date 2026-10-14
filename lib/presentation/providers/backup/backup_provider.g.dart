// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(backupDataSource)
const backupDataSourceProvider = BackupDataSourceProvider._();

final class BackupDataSourceProvider
    extends
        $FunctionalProvider<
          BackupDataSource,
          BackupDataSource,
          BackupDataSource
        >
    with $Provider<BackupDataSource> {
  const BackupDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupDataSourceHash();

  @$internal
  @override
  $ProviderElement<BackupDataSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackupDataSource create(Ref ref) {
    return backupDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupDataSource>(value),
    );
  }
}

String _$backupDataSourceHash() => r'9d1acae6871da8ef07e49ea00974d7d793ab17cf';

@ProviderFor(incomingBackupFileChannel)
const incomingBackupFileChannelProvider = IncomingBackupFileChannelProvider._();

final class IncomingBackupFileChannelProvider
    extends
        $FunctionalProvider<
          IncomingBackupFileChannel,
          IncomingBackupFileChannel,
          IncomingBackupFileChannel
        >
    with $Provider<IncomingBackupFileChannel> {
  const IncomingBackupFileChannelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomingBackupFileChannelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomingBackupFileChannelHash();

  @$internal
  @override
  $ProviderElement<IncomingBackupFileChannel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IncomingBackupFileChannel create(Ref ref) {
    return incomingBackupFileChannel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IncomingBackupFileChannel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IncomingBackupFileChannel>(value),
    );
  }
}

String _$incomingBackupFileChannelHash() =>
    r'd22435a8336f27febcd03265b7f9be5f13755fec';

@ProviderFor(backupRepository)
const backupRepositoryProvider = BackupRepositoryProvider._();

final class BackupRepositoryProvider
    extends
        $FunctionalProvider<
          BackupRepository,
          BackupRepository,
          BackupRepository
        >
    with $Provider<BackupRepository> {
  const BackupRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupRepositoryHash();

  @$internal
  @override
  $ProviderElement<BackupRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackupRepository create(Ref ref) {
    return backupRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupRepository>(value),
    );
  }
}

String _$backupRepositoryHash() => r'c8d349f45ed407ecbbab5abd3eb5731a942bf672';
