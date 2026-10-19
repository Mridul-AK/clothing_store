import '../../domain/entities/cart_item.dart';

abstract interface class CartLocalDataSource {
  Future<List<CartItem>> getItems();

  Future<void> upsert(CartItem item);

  Future<void> remove(int productId);

  Future<void> clear();
}

class InMemoryCartDataSource implements CartLocalDataSource {
  final Map<int, CartItem> _items = {};

  @override
  Future<List<CartItem>> getItems() async => List.unmodifiable(_items.values);

  @override
  Future<void> upsert(CartItem item) async => _items[item.product.id] = item;

  @override
  Future<void> remove(int productId) async => _items.remove(productId);

  @override
  Future<void> clear() async => _items.clear();
}
