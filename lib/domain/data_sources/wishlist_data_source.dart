import 'package:pocket_guard/domain/entities/wishlist_item.dart';

abstract class WishlistDataSource {
  Future<void> createItem(WishlistItemEntity item);
  Future<void> deleteItem(String id);
  Future<List<WishlistItemEntity>> getAllItems();
  Future<WishlistItemEntity?> getItemById(String id);
  Future<void> updateItem(String id, WishlistItemEntity item);
}
