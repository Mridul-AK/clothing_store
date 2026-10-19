import 'package:clothing_store/features/cart/domain/entities/cart.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('Cart totals', () {
    test('an empty cart totals zero', () {
      expect(Cart.empty.totalAmount, 0);
      expect(Cart.empty.totalItems, 0);
      expect(Cart.empty.isEmpty, isTrue);
    });

    test('total amount is the sum of price × quantity per line', () {
      final cart = cartOf({tShirt: 2, jacket: 1});

      // 19.99 × 2 + 49.50 = 89.48
      expect(cart.totalAmount, 89.48);
    });

    test('total items counts units, not lines', () {
      final cart = cartOf({tShirt: 2, jacket: 3});

      expect(cart.items.length, 2);
      expect(cart.totalItems, 5);
    });

    test('totals are exact to the cent (no floating-point drift)', () {
      // In plain doubles 0.1 + 0.2 == 0.30000000000000004.
      final cart = cartOf({dime: 1, twentyCents: 1});

      expect(cart.totalAmount, 0.30);
    });

    test('quantityOf returns 0 for products not in the cart', () {
      final cart = cartOf({tShirt: 4});

      expect(cart.quantityOf(tShirt.id), 4);
      expect(cart.quantityOf(jacket.id), 0);
    });
  });
}
