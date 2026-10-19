import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class RemoveFromCartUseCase implements UseCase<Cart, int> {
  const RemoveFromCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<Cart>> call(int productId) => _repository.removeItem(productId);
}
