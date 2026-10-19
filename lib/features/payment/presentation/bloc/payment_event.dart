part of 'payment_bloc.dart';

sealed class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

final class InitiatePayment extends PaymentEvent {
  const InitiatePayment();
}
