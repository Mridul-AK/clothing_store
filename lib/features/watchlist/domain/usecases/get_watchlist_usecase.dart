import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../products/domain/entities/product.dart';
import '../repositories/watchlist_repository.dart';

class GetWatchlistUseCase implements UseCase<List<Product>, NoParams> {
  const GetWatchlistUseCase(this._repository);

  final WatchlistRepository _repository;

  @override
  Future<Result<List<Product>>> call(NoParams params) =>
      _repository.getWatchlist();
}
