import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../products/domain/entities/product.dart';
import '../repositories/watchlist_repository.dart';

class RemoveFromWatchlistUseCase implements UseCase<List<Product>, int> {
  const RemoveFromWatchlistUseCase(this._repository);

  final WatchlistRepository _repository;

  @override
  Future<Result<List<Product>>> call(int productId) =>
      _repository.remove(productId);
}
