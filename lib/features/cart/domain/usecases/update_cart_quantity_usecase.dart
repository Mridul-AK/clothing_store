import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/cart.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class UpdateCartQuantityUseCase implements UseCase<Cart, UpdateQuantityParams> {
  const UpdateCartQuantityUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<Cart>> call(UpdateQuantityParams params) async {
    final current = await _repository.getCart();
    return current.andThen<Cart>((cart) async {
      final item = cart.itemFor(params.productId);
      if (item == null) {
        return const Err(CartFailure('This item is no longer in your cart.'));
      }
      if (params.quantity < 1) {
        return _repository.removeItem(params.productId);
      }
      if (params.quantity > CartItem.maxQuantity) {
        return const Err(
          CartFailure('Maximum quantity per item is ${CartItem.maxQuantity}.'),
        );
      }
      return _repository.saveItem(item.copyWith(quantity: params.quantity));
    });
  }
}

class UpdateQuantityParams extends Equatable {
  const UpdateQuantityParams({required this.productId, required this.quantity});

  final int productId;
  final int quantity;

  @override
  List<Object?> get props => [productId, quantity];
}
