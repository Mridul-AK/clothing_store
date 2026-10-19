import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../datasources/watchlist_local_data_source.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  const WatchlistRepositoryImpl(this._dataSource);

  final WatchlistLocalDataSource _dataSource;

  @override
  Future<Result<List<Product>>> getWatchlist() =>
      _guard(() async => _dataSource.getAll());

  @override
  Future<Result<List<Product>>> add(Product product) => _guard(() async {
    await _dataSource.add(product);
    return _dataSource.getAll();
  });

  @override
  Future<Result<List<Product>>> remove(int productId) => _guard(() async {
    await _dataSource.remove(productId);
    return _dataSource.getAll();
  });

  Future<Result<List<Product>>> _guard(
    Future<List<Product>> Function() action,
  ) async {
    try {
      return Ok(await action());
    } on Exception {
      return const Err(DataFailure('Could not update your watchlist.'));
    }
  }
}
