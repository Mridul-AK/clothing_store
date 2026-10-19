part of 'cart_bloc.dart';

enum CartStatus { initial, loading, success, empty, failure }

final class CartNotice {
  CartNotice.info(this.message) : isError = false;
  CartNotice.error(this.message) : isError = true;

  final String message;
  final bool isError;
}

final class CartState extends Equatable {
  const CartState({
    this.status = CartStatus.initial,
    this.cart = Cart.empty,
    this.errorMessage,
    this.notice,
  });

  final CartStatus status;
  final Cart cart;

  final String? errorMessage;

  final CartNotice? notice;

  @override
  List<Object?> get props => [status, cart, errorMessage, notice];
}
