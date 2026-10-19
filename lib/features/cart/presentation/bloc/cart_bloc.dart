import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/cart.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/clear_cart_usecase.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/remove_from_cart_usecase.dart';
import '../../domain/usecases/update_cart_quantity_usecase.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc({
    required GetCartUseCase getCart,
    required AddToCartUseCase addToCart,
    required RemoveFromCartUseCase removeFromCart,
    required UpdateCartQuantityUseCase updateQuantity,
    required ClearCartUseCase clearCart,
  }) : _getCart = getCart,
       _addToCart = addToCart,
       _removeFromCart = removeFromCart,
       _updateQuantity = updateQuantity,
       _clearCart = clearCart,
       super(const CartState()) {
    on<CartEvent>(_onEvent, transformer: sequential());
  }

  final GetCartUseCase _getCart;
  final AddToCartUseCase _addToCart;
  final RemoveFromCartUseCase _removeFromCart;
  final UpdateCartQuantityUseCase _updateQuantity;
  final ClearCartUseCase _clearCart;

  Future<void> _onEvent(CartEvent event, Emitter<CartState> emit) async {
    switch (event) {
      case LoadCart():
        if (state.status == CartStatus.initial) {
          emit(const CartState(status: CartStatus.loading));
        }
        _emitResult(await _getCart(const NoParams()), emit);

      case AddToCart(:final product):
        _emitResult(
          await _addToCart(product),
          emit,
          successMessage: '${product.name} added to cart',
        );

      case RemoveFromCart(:final productId):
        final name = state.cart.itemFor(productId)?.product.name;
        _emitResult(
          await _removeFromCart(productId),
          emit,
          successMessage: name == null ? null : '$name removed from cart',
        );

      case IncreaseQuantity(:final productId):
        _emitResult(await _changeQuantityBy(productId, 1), emit);

      case DecreaseQuantity(:final productId):
        _emitResult(await _changeQuantityBy(productId, -1), emit);

      case ClearCart():
        _emitResult(
          await _clearCart(const NoParams()),
          emit,
          successMessage: 'Cart cleared',
        );
    }
  }

  Future<Result<Cart>> _changeQuantityBy(int productId, int delta) {
    return _updateQuantity(
      UpdateQuantityParams(
        productId: productId,
        quantity: state.cart.quantityOf(productId) + delta,
      ),
    );
  }

  void _emitResult(
    Result<Cart> result,
    Emitter<CartState> emit, {
    String? successMessage,
  }) {
    emit(
      result.fold(
        (failure) {
          final hasCart =
              state.status == CartStatus.success ||
              state.status == CartStatus.empty;
          return hasCart
              ? CartState(
                  status: state.status,
                  cart: state.cart,
                  notice: CartNotice.error(failure.message),
                )
              : CartState(
                  status: CartStatus.failure,
                  errorMessage: failure.message,
                );
        },
        (cart) => CartState(
          status: cart.isEmpty ? CartStatus.empty : CartStatus.success,
          cart: cart,
          notice: successMessage == null
              ? null
              : CartNotice.info(successMessage),
        ),
      ),
    );
  }
}
