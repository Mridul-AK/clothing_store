import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../cart/domain/repositories/cart_repository.dart';
import '../entities/payment_receipt.dart';
import '../repositories/payment_repository.dart';

class ProcessDummyPaymentUseCase implements UseCase<PaymentReceipt, NoParams> {
  const ProcessDummyPaymentUseCase({
    required PaymentRepository paymentRepository,
    required CartRepository cartRepository,
  }) : _paymentRepository = paymentRepository,
       _cartRepository = cartRepository;

  final PaymentRepository _paymentRepository;
  final CartRepository _cartRepository;

  @override
  Future<Result<PaymentReceipt>> call(NoParams params) async {
    final cartResult = await _cartRepository.getCart();

    return cartResult.andThen<PaymentReceipt>((cart) async {
      if (cart.isEmpty) {
        return const Err(PaymentFailure('Your cart is empty.'));
      }

      final payment = await _paymentRepository.processPayment(
        amount: cart.totalAmount,
        itemCount: cart.totalItems,
      );

      return payment.andThen<PaymentReceipt>((receipt) async {
        await _cartRepository.clear();
        return Ok(receipt);
      });
    });
  }
}
