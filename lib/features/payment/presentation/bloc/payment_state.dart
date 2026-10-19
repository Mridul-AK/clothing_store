part of 'payment_bloc.dart';

sealed class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

final class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

final class PaymentProcessing extends PaymentState {
  const PaymentProcessing();
}

final class PaymentSuccess extends PaymentState {
  const PaymentSuccess(this.receipt);

  final PaymentReceipt receipt;

  @override
  List<Object?> get props => [receipt];
}

final class PaymentError extends PaymentState {
  const PaymentError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
