import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

final class DataFailure extends Failure {
  const DataFailure(super.message);
}

final class CartFailure extends Failure {
  const CartFailure(super.message);
}

final class PaymentFailure extends Failure {
  const PaymentFailure(super.message);
}
