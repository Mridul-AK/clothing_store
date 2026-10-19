import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../validators/credentials_validator.dart';

class LoginUseCase implements UseCase<User, LoginParams> {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<User>> call(LoginParams params) async {
    final error =
        CredentialsValidator.validateEmail(params.email) ??
        CredentialsValidator.validatePassword(params.password);
    if (error != null) return Err(ValidationFailure(error));

    return _repository.login(
      email: params.email.trim().toLowerCase(),
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  const LoginParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
