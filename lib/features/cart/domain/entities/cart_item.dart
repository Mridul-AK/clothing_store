import 'package:equatable/equatable.dart';

import '../../../../core/utils/formatters.dart';
import '../../../products/domain/entities/product.dart';

class CartItem extends Equatable {
  const CartItem({required this.product, required this.quantity});

  static const int maxQuantity = 10;

  final Product product;
  final int quantity;

  int get lineTotalInCents => toCents(product.price) * quantity;

  double get lineTotal => lineTotalInCents / 100;

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);

  @override
  List<Object?> get props => [product, quantity];
}
