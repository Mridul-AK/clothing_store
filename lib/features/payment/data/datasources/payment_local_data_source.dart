import 'dart:math';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/payment_receipt.dart';

abstract interface class PaymentLocalDataSource {
  Future<PaymentReceipt> charge({
    required double amount,
    required int itemCount,
  });
}

class DummyPaymentGateway implements PaymentLocalDataSource {
  DummyPaymentGateway({
    this.latency = const Duration(seconds: 2),
    Random? random,
    DateTime Function()? clock,
  }) : _random = random ?? Random.secure(),
       _clock = clock ?? DateTime.now;

  final Duration latency;
  final Random _random;
  final DateTime Function() _clock;

  static const String _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  @override
  Future<PaymentReceipt> charge({
    required double amount,
    required int itemCount,
  }) async {
    await Future<void>.delayed(latency);

    if (amount <= 0) {
      throw const PaymentException('Payment amount must be greater than zero.');
    }

    final now = _clock();
    return PaymentReceipt(
      orderId: _orderId(now),
      amountPaid: amount,
      itemCount: itemCount,
      paidAt: now,
    );
  }

  String _orderId(DateTime now) {
    String two(int n) => n.toString().padLeft(2, '0');
    final date = '${now.year}${two(now.month)}${two(now.day)}';
    final suffix = List.generate(
      6,
      (_) => _alphabet[_random.nextInt(_alphabet.length)],
    ).join();
    return 'ORD-$date-$suffix';
  }
}
