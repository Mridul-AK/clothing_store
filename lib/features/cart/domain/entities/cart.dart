import 'package:equatable/equatable.dart';

import 'cart_item.dart';

class Cart extends Equatable {
  const Cart({this.items = const []});

  static const Cart empty = Cart();

  final List<CartItem> items;

  bool get isEmpty => items.isEmpty;

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      items.fold(0, (sum, item) => sum + item.lineTotalInCents) / 100;

  CartItem? itemFor(int productId) {
    for (final item in items) {
      if (item.product.id == productId) return item;
    }
    return null;
  }

  int quantityOf(int productId) => itemFor(productId)?.quantity ?? 0;

  @override
  List<Object?> get props => [items];
}
