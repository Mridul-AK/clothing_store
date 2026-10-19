import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../products/domain/entities/product.dart';
import '../entities/cart.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class AddToCartUseCase implements UseCase<Cart, Product> {
  const AddToCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<Cart>> call(Product product) async {
    final current = await _repository.getCart();
    return current.andThen<Cart>((cart) async {
      final quantity = cart.quantityOf(product.id);
      if (quantity >= CartItem.maxQuantity) {
        return Err(
          CartFailure(
            'You can add at most ${CartItem.maxQuantity} of ${product.name}.',
          ),
        );
      }
      return _repository.saveItem(
        CartItem(product: product, quantity: quantity + 1),
      );
    });
  }
}
