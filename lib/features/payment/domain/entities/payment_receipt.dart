import 'package:equatable/equatable.dart';

class PaymentReceipt extends Equatable {
  const PaymentReceipt({
    required this.orderId,
    required this.amountPaid,
    required this.itemCount,
    required this.paidAt,
  });

  final String orderId;
  final double amountPaid;
  final int itemCount;
  final DateTime paidAt;

  @override
  List<Object?> get props => [orderId, amountPaid, itemCount, paidAt];
}
