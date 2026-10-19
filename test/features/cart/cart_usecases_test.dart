import 'package:clothing_store/core/error/failures.dart';
import 'package:clothing_store/core/error/result.dart';
import 'package:clothing_store/core/usecase/usecase.dart';
import 'package:clothing_store/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:clothing_store/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:clothing_store/features/cart/domain/entities/cart.dart';
import 'package:clothing_store/features/cart/domain/entities/cart_item.dart';
import 'package:clothing_store/features/cart/domain/repositories/cart_repository.dart';
import 'package:clothing_store/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:clothing_store/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:clothing_store/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:clothing_store/features/cart/domain/usecases/update_cart_quantity_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

Cart _cart(Result<Cart> result) =>
    result.fold((f) => fail('Expected Ok, got $f'), (cart) => cart);

void main() {
  late CartRepository repository;
  late AddToCartUseCase addToCart;
  late UpdateCartQuantityUseCase updateQuantity;

  setUp(() {
    repository = CartRepositoryImpl(InMemoryCartDataSource());
    addToCart = AddToCartUseCase(repository);
    updateQuantity = UpdateCartQuantityUseCase(repository);
  });

  group('AddToCartUseCase', () {
    test(
      'adding the same product twice bumps quantity on a single line',
      () async {
        await addToCart(tShirt);
        final cart = _cart(await addToCart(tShirt));

        expect(cart.items, [const CartItem(product: tShirt, quantity: 2)]);
      },
    );

    test('rejects adding beyond the per-item maximum', () async {
      for (var i = 0; i < CartItem.maxQuantity; i++) {
        await addToCart(tShirt);
      }

      final result = await addToCart(tShirt);

      expect(result.fold((f) => f, (_) => null), isA<CartFailure>());
      expect(
        _cart(await repository.getCart()).quantityOf(tShirt.id),
        CartItem.maxQuantity,
      );
    });
  });

  group('UpdateCartQuantityUseCase', () {
    test('sets the new quantity and keeps line order', () async {
      await addToCart(tShirt);
      await addToCart(jacket);

      final cart = _cart(
        await updateQuantity(
          UpdateQuantityParams(productId: tShirt.id, quantity: 3),
        ),
      );

      expect(cart.items.map((i) => i.product), [tShirt, jacket]);
      expect(cart.quantityOf(tShirt.id), 3);
    });

    test('quantity below 1 removes the line', () async {
      await addToCart(tShirt);

      final cart = _cart(
        await updateQuantity(
          UpdateQuantityParams(productId: tShirt.id, quantity: 0),
        ),
      );

      expect(cart.isEmpty, isTrue);
    });

    test('fails for a product that is not in the cart', () async {
      final result = await updateQuantity(
        UpdateQuantityParams(productId: jacket.id, quantity: 2),
      );

      expect(result.fold((f) => f, (_) => null), isA<CartFailure>());
    });
  });

  test('RemoveFromCartUseCase drops the whole line', () async {
    await addToCart(tShirt);
    await addToCart(tShirt);
    await addToCart(jacket);

    final cart = _cart(await RemoveFromCartUseCase(repository)(tShirt.id));

    expect(cart.items.map((i) => i.product), [jacket]);
  });

  test('ClearCartUseCase empties the cart', () async {
    await addToCart(tShirt);
    await addToCart(jacket);

    final cart = _cart(await ClearCartUseCase(repository)(const NoParams()));

    expect(cart.isEmpty, isTrue);
    expect(cart.totalAmount, 0);
  });
}
