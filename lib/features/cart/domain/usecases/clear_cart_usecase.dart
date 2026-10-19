import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class ClearCartUseCase implements UseCase<Cart, NoParams> {
  const ClearCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<Cart>> call(NoParams params) => _repository.clear();
}
