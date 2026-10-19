part of 'cart_bloc.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

final class LoadCart extends CartEvent {
  const LoadCart();
}

final class AddToCart extends CartEvent {
  const AddToCart(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

final class RemoveFromCart extends CartEvent {
  const RemoveFromCart(this.productId);

  final int productId;

  @override
  List<Object?> get props => [productId];
}

final class IncreaseQuantity extends CartEvent {
  const IncreaseQuantity(this.productId);

  final int productId;

  @override
  List<Object?> get props => [productId];
}

final class DecreaseQuantity extends CartEvent {
  const DecreaseQuantity(this.productId);

  final int productId;

  @override
  List<Object?> get props => [productId];
}

final class ClearCart extends CartEvent {
  const ClearCart();
}
