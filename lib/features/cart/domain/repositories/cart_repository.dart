import '../../../../core/error/result.dart';
import '../entities/cart.dart';
import '../entities/cart_item.dart';

abstract interface class CartRepository {
  Future<Result<Cart>> getCart();

  Future<Result<Cart>> saveItem(CartItem item);

  Future<Result<Cart>> removeItem(int productId);

  Future<Result<Cart>> clear();
}
