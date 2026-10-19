import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase implements UseCase<List<Product>, NoParams> {
  const GetProductsUseCase(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<List<Product>>> call(NoParams params) =>
      _repository.getProducts();
}
