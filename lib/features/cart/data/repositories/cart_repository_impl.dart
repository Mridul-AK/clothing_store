import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl(this._dataSource);

  final CartLocalDataSource _dataSource;

  @override
  Future<Result<Cart>> getCart() => _guard(() async {});

  @override
  Future<Result<Cart>> saveItem(CartItem item) =>
      _guard(() => _dataSource.upsert(item));

  @override
  Future<Result<Cart>> removeItem(int productId) =>
      _guard(() => _dataSource.remove(productId));

  @override
  Future<Result<Cart>> clear() => _guard(_dataSource.clear);

  Future<Result<Cart>> _guard(Future<void> Function() mutation) async {
    try {
      await mutation();
      return Ok(Cart(items: await _dataSource.getItems()));
    } on Exception {
      return const Err(DataFailure('Could not update your cart.'));
    }
  }
}
