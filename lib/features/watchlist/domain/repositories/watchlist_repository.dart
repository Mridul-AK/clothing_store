import '../../../../core/error/result.dart';
import '../../../products/domain/entities/product.dart';

abstract interface class WatchlistRepository {
  Future<Result<List<Product>>> getWatchlist();

  Future<Result<List<Product>>> add(Product product);

  Future<Result<List<Product>>> remove(int productId);
}
