import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/payment_receipt.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_local_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  const PaymentRepositoryImpl(this._gateway);

  final PaymentLocalDataSource _gateway;

  @override
  Future<Result<PaymentReceipt>> processPayment({
    required double amount,
    required int itemCount,
  }) async {
    try {
      return Ok(await _gateway.charge(amount: amount, itemCount: itemCount));
    } on PaymentException catch (e) {
      return Err(PaymentFailure(e.message));
    }
  }
}
