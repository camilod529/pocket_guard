import 'package:drift/drift.dart';
import 'package:pocket_guard/config/database/database.dart' as db;
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/data_sources/wishlist_data_source.dart';
import 'package:pocket_guard/domain/entities/wishlist_item.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';
import 'package:pocket_guard/infrastructure/errors/drift_exception_handler.dart';

/// Plain CRUD - a wishlist item never touches account balances. Buying one
/// goes through the normal transaction flow (and, optionally, a savings
/// goal withdrawal), then marks the item purchased via [updateItem].
class WishlistDriftDataSourceImpl extends WishlistDataSource {
  WishlistDriftDataSourceImpl({AppDatabase? database})
    : database = database ?? db.database;

  final AppDatabase database;
  final DriftExceptionHandler _exceptionHandler = DriftExceptionHandler();

  @override
  Future<void> createItem(WishlistItemEntity item) async {
    try {
      await database.into(database.wishlistItems).insert(_toCompanion(item));
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'create wishlist item',
        entityName: 'wishlist item',
      );
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    try {
      final deleted = await (database.delete(
        database.wishlistItems,
      )..where((tbl) => tbl.id.equals(id))).go();

      if (deleted == 0) {
        throw DataNotFoundException(entityName: 'wishlist item');
      }
    } catch (e, stackTrace) {
      if (e is DataException) rethrow;

      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'delete wishlist item',
        entityName: 'wishlist item',
      );
    }
  }

  @override
  Future<List<WishlistItemEntity>> getAllItems() async {
    try {
      final rows = await (database.select(
        database.wishlistItems,
      )..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)])).get();
      return rows.map(_toEntity).toList();
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'get all wishlist items',
        entityName: 'wishlist item',
      );
    }
  }

  @override
  Future<WishlistItemEntity?> getItemById(String id) async {
    try {
      final row = await (database.select(
        database.wishlistItems,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      if (row == null) return null;
      return _toEntity(row);
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'get wishlist item',
        entityName: 'wishlist item',
      );
    }
  }

  @override
  Future<void> updateItem(String id, WishlistItemEntity item) async {
    try {
      final updated = await (database.update(
        database.wishlistItems,
      )..where((tbl) => tbl.id.equals(id))).write(_toCompanion(item));

      if (updated == 0) {
        throw DataNotFoundException(entityName: 'wishlist item');
      }
    } catch (e, stackTrace) {
      if (e is DataException) rethrow;

      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'update wishlist item',
        entityName: 'wishlist item',
      );
    }
  }

  WishlistItemsCompanion _toCompanion(WishlistItemEntity item) {
    return WishlistItemsCompanion(
      name: Value(item.name),
      price: Value(item.price),
      currency: Value(item.currency),
      categoryId: Value(item.categoryId),
      goalId: Value(item.goalId),
      purchasedAt: Value(item.purchasedAt),
    );
  }

  WishlistItemEntity _toEntity(WishlistItem row) {
    return WishlistItemEntity(
      id: row.id,
      name: row.name,
      price: row.price,
      currency: row.currency,
      categoryId: row.categoryId,
      goalId: row.goalId,
      purchasedAt: row.purchasedAt,
      createdAt: row.createdAt,
    );
  }
}
