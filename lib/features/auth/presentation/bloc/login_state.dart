part of 'login_bloc.dart';

enum LoginStatus { initial, submitting, success, failure }

final class LoginState extends Equatable {
  const LoginState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.user,
  });

  final String email;
  final String password;

  final String? emailError;
  final String? passwordError;

  final LoginStatus status;

  final String? errorMessage;

  final User? user;

  bool get isFormValid =>
      CredentialsValidator.isValid(email: email, password: password);

  bool get canSubmit => isFormValid && status != LoginStatus.submitting;

  LoginState copyWith({
    String? email,
    String? password,
    String? Function()? emailError,
    String? Function()? passwordError,
    LoginStatus? status,
    String? Function()? errorMessage,
    User? Function()? user,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: emailError != null ? emailError() : this.emailError,
      passwordError: passwordError != null
          ? passwordError()
          : this.passwordError,
      status: status ?? this.status,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      user: user != null ? user() : this.user,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    emailError,
    passwordError,
    status,
    errorMessage,
    user,
  ];
}
