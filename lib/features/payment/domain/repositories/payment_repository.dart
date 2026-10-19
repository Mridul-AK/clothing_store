import '../../../../core/error/result.dart';
import '../entities/payment_receipt.dart';

abstract interface class PaymentRepository {
  Future<Result<PaymentReceipt>> processPayment({
    required double amount,
    required int itemCount,
  });
}
