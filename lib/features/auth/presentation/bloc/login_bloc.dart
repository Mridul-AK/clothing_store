import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/validators/credentials_validator.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required LoginUseCase login})
    : _login = login,
      super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted, transformer: droppable());
  }

  final LoginUseCase _login;

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    emit(
      state.copyWith(
        email: event.email,
        emailError: () => event.email.isEmpty
            ? null
            : CredentialsValidator.validateEmail(event.email),
        status: LoginStatus.initial,
        errorMessage: () => null,
      ),
    );
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(
      state.copyWith(
        password: event.password,
        passwordError: () => event.password.isEmpty
            ? null
            : CredentialsValidator.validatePassword(event.password),
        status: LoginStatus.initial,
        errorMessage: () => null,
      ),
    );
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.isFormValid) {
      emit(
        state.copyWith(
          emailError: () => CredentialsValidator.validateEmail(state.email),
          passwordError: () =>
              CredentialsValidator.validatePassword(state.password),
        ),
      );
      return;
    }

    emit(
      state.copyWith(status: LoginStatus.submitting, errorMessage: () => null),
    );

    final result = await _login(
      LoginParams(email: state.email, password: state.password),
    );

    emit(
      result.fold(
        (failure) => state.copyWith(
          status: LoginStatus.failure,
          errorMessage: () => failure.message,
        ),
        (user) => state.copyWith(status: LoginStatus.success, user: () => user),
      ),
    );
  }
}
