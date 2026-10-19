import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/payment_receipt.dart';
import '../../domain/usecases/process_dummy_payment_usecase.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc({required ProcessDummyPaymentUseCase processPayment})
    : _processPayment = processPayment,
      super(const PaymentInitial()) {
    on<InitiatePayment>(_onInitiate, transformer: droppable());
  }

  final ProcessDummyPaymentUseCase _processPayment;

  Future<void> _onInitiate(
    InitiatePayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentProcessing());

    final result = await _processPayment(const NoParams());

    emit(
      result.fold(
        (failure) => PaymentError(failure.message),
        PaymentSuccess.new,
      ),
    );
  }
}
