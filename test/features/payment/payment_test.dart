import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:clothing_store/core/error/failures.dart';
import 'package:clothing_store/core/usecase/usecase.dart';
import 'package:clothing_store/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:clothing_store/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:clothing_store/features/cart/domain/entities/cart_item.dart';
import 'package:clothing_store/features/cart/domain/repositories/cart_repository.dart';
import 'package:clothing_store/features/payment/data/datasources/payment_local_data_source.dart';
import 'package:clothing_store/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:clothing_store/features/payment/domain/usecases/process_dummy_payment_usecase.dart';
import 'package:clothing_store/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  late CartRepository cartRepository;
  late ProcessDummyPaymentUseCase pay;
  final paidAt = DateTime(2026, 10, 16, 14, 5);

  setUp(() {
    cartRepository = CartRepositoryImpl(InMemoryCartDataSource());
    pay = ProcessDummyPaymentUseCase(
      cartRepository: cartRepository,
      paymentRepository: PaymentRepositoryImpl(
        DummyPaymentGateway(
          latency: Duration.zero,
          random: Random(42),
          clock: () => paidAt,
        ),
      ),
    );
  });

  group('ProcessDummyPaymentUseCase', () {
    test(
      'charges the cart total, returns a receipt and clears the cart',
      () async {
        await cartRepository.saveItem(
          const CartItem(product: tShirt, quantity: 2),
        );
        await cartRepository.saveItem(
          const CartItem(product: jacket, quantity: 1),
        );

        final result = await pay(const NoParams());
        final receipt = result.fold((f) => fail('$f'), (r) => r);

        expect(receipt.amountPaid, 89.48);
        expect(receipt.itemCount, 3);
        expect(receipt.paidAt, paidAt);
        expect(receipt.orderId, matches(RegExp(r'^ORD-20261016-[A-Z2-9]{6}$')));

        final cartAfter = (await cartRepository.getCart()).fold(
          (f) => fail('$f'),
          (c) => c,
        );
        expect(cartAfter.isEmpty, isTrue);
      },
    );

    test('refuses to pay for an empty cart', () async {
      final result = await pay(const NoParams());

      expect(
        result.fold((f) => f, (_) => null),
        const PaymentFailure('Your cart is empty.'),
      );
    });
  });

  group('PaymentBloc', () {
    blocTest<PaymentBloc, PaymentState>(
      'emits [processing, success] for a non-empty cart',
      setUp: () =>
          cartRepository.saveItem(const CartItem(product: tShirt, quantity: 1)),
      build: () => PaymentBloc(processPayment: pay),
      wait: const Duration(milliseconds: 20),
      act: (bloc) => bloc.add(const InitiatePayment()),
      expect: () => [
        const PaymentProcessing(),
        isA<PaymentSuccess>().having(
          (s) => s.receipt.amountPaid,
          'amountPaid',
          19.99,
        ),
      ],
    );

    blocTest<PaymentBloc, PaymentState>(
      'emits [processing, error] for an empty cart',
      build: () => PaymentBloc(processPayment: pay),
      wait: const Duration(milliseconds: 20),
      act: (bloc) => bloc.add(const InitiatePayment()),
      expect: () => const [
        PaymentProcessing(),
        PaymentError('Your cart is empty.'),
      ],
    );
  });
}
