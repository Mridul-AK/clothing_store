import 'package:bloc_test/bloc_test.dart';
import 'package:clothing_store/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:clothing_store/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:clothing_store/features/cart/domain/entities/cart_item.dart';
import 'package:clothing_store/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:clothing_store/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:clothing_store/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:clothing_store/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:clothing_store/features/cart/domain/usecases/update_cart_quantity_usecase.dart';
import 'package:clothing_store/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

CartBloc _buildBloc() {
  final repository = CartRepositoryImpl(InMemoryCartDataSource());
  return CartBloc(
    getCart: GetCartUseCase(repository),
    addToCart: AddToCartUseCase(repository),
    removeFromCart: RemoveFromCartUseCase(repository),
    updateQuantity: UpdateCartQuantityUseCase(repository),
    clearCart: ClearCartUseCase(repository),
  );
}

Matcher _cartWith({
  required CartStatus status,
  required int items,
  required double total,
}) => isA<CartState>()
    .having((s) => s.status, 'status', status)
    .having((s) => s.cart.totalItems, 'totalItems', items)
    .having((s) => s.cart.totalAmount, 'totalAmount', total);

void main() {
  blocTest<CartBloc, CartState>(
    'loading a fresh cart goes loading → empty',
    build: _buildBloc,
    act: (bloc) => bloc.add(const LoadCart()),
    expect: () => [
      _cartWith(status: CartStatus.loading, items: 0, total: 0),
      _cartWith(status: CartStatus.empty, items: 0, total: 0),
    ],
  );

  blocTest<CartBloc, CartState>(
    'add, increase, decrease and remove keep totals up to date',
    build: _buildBloc,
    act: (bloc) => bloc
      ..add(const AddToCart(tShirt)) // 1 × 19.99
      ..add(const AddToCart(jacket)) // + 1 × 49.50
      ..add(IncreaseQuantity(tShirt.id)) // tee → 2
      ..add(DecreaseQuantity(jacket.id)) // jacket → 0, line removed
      ..add(RemoveFromCart(tShirt.id)),
    expect: () => [
      _cartWith(status: CartStatus.success, items: 1, total: 19.99),
      _cartWith(status: CartStatus.success, items: 2, total: 69.49),
      _cartWith(status: CartStatus.success, items: 3, total: 89.48),
      _cartWith(status: CartStatus.success, items: 2, total: 39.98),
      _cartWith(status: CartStatus.empty, items: 0, total: 0),
    ],
  );

  blocTest<CartBloc, CartState>(
    'adding a product emits an info notice for the snackbar',
    build: _buildBloc,
    act: (bloc) => bloc.add(const AddToCart(tShirt)),
    expect: () => [
      isA<CartState>()
          .having((s) => s.notice?.message, 'notice', 'Tee added to cart')
          .having((s) => s.notice?.isError, 'isError', isFalse),
    ],
  );

  blocTest<CartBloc, CartState>(
    'going past the max quantity keeps the cart and reports an error notice',
    build: _buildBloc,
    act: (bloc) async {
      for (var i = 0; i <= CartItem.maxQuantity; i++) {
        bloc.add(const AddToCart(tShirt));
      }
    },
    skip: CartItem.maxQuantity,
    expect: () => [
      isA<CartState>()
          .having((s) => s.status, 'status', CartStatus.success)
          .having((s) => s.cart.totalItems, 'totalItems', CartItem.maxQuantity)
          .having((s) => s.notice?.isError, 'isError', isTrue),
    ],
  );

  blocTest<CartBloc, CartState>(
    'ClearCart empties the cart',
    build: _buildBloc,
    act: (bloc) => bloc
      ..add(const AddToCart(tShirt))
      ..add(const AddToCart(jacket))
      ..add(const ClearCart()),
    skip: 2,
    expect: () => [_cartWith(status: CartStatus.empty, items: 0, total: 0)],
  );
}
