import '../../../products/domain/entities/product.dart';

abstract interface class WatchlistLocalDataSource {
  Future<List<Product>> getAll();

  Future<void> add(Product product);

  Future<void> remove(int productId);
}

class InMemoryWatchlistDataSource implements WatchlistLocalDataSource {
  final Map<int, Product> _items = {};

  @override
  Future<List<Product>> getAll() async => List.unmodifiable(_items.values);

  @override
  Future<void> add(Product product) async =>
      _items.putIfAbsent(product.id, () => product);

  @override
  Future<void> remove(int productId) async => _items.remove(productId);
}
