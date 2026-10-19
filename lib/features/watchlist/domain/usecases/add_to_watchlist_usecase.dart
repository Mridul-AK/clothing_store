import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../products/domain/entities/product.dart';
import '../repositories/watchlist_repository.dart';

class AddToWatchlistUseCase implements UseCase<List<Product>, Product> {
  const AddToWatchlistUseCase(this._repository);

  final WatchlistRepository _repository;

  @override
  Future<Result<List<Product>>> call(Product product) async {
    final current = await _repository.getWatchlist();
    return current.andThen<List<Product>>((items) async {
      if (items.any((p) => p.id == product.id)) return Ok(items);
      return _repository.add(product);
    });
  }
}
