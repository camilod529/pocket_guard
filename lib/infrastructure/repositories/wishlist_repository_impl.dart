import 'package:pocket_guard/domain/data_sources/wishlist_data_source.dart';
import 'package:pocket_guard/domain/entities/wishlist_item.dart';
import 'package:pocket_guard/domain/repositories/wishlist_repository.dart';
import 'package:pocket_guard/domain/services/logger_service.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';
import 'package:pocket_guard/infrastructure/services/logger_service_impl.dart';

class WishlistRepositoryImpl extends WishlistRepository {
  final WishlistDataSource _dataSource;
  late final LoggerService _logger;

  WishlistRepositoryImpl({required WishlistDataSource dataSource})
    : _dataSource = dataSource {
    _logger = LoggerServiceImpl(runtimeType.toString());
  }

  @override
  Future<void> createItem(WishlistItemEntity item) {
    _logger.info('Creating wishlist item: ${item.name}');
    return _run('create wishlist item', () async {
      await _dataSource.createItem(item);
      _logger.info('Wishlist item created successfully: ${item.name}');
    });
  }

  @override
  Future<void> deleteItem(String id) {
    _logger.info('Deleting wishlist item: $id');
    return _run('delete wishlist item', () async {
      await _dataSource.deleteItem(id);
      _logger.info('Wishlist item deleted successfully: $id');
    });
  }

  @override
  Future<List<WishlistItemEntity>> getAllItems() {
    _logger.debug('Getting all wishlist items');
    return _run('get all wishlist items', () async {
      final items = await _dataSource.getAllItems();
      _logger.debug('Found ${items.length} wishlist items');
      return items;
    });
  }

  @override
  Future<WishlistItemEntity?> getItemById(String id) {
    _logger.debug('Getting wishlist item by ID: $id');
    return _run('get wishlist item', () => _dataSource.getItemById(id));
  }

  @override
  Future<void> updateItem(String id, WishlistItemEntity item) {
    _logger.info('Updating wishlist item: $id');
    return _run('update wishlist item', () async {
      await _dataSource.updateItem(id, item);
      _logger.info('Wishlist item updated successfully: $id');
    });
  }

  /// Same log-and-rethrow wrapper as SavingsGoalRepositoryImpl.
  Future<T> _run<T>(String operation, Future<T> Function() action) async {
    try {
      return await action();
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to $operation: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error trying to $operation',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnknownDataException(
        message: 'Failed to $operation: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
