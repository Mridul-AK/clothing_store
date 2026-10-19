import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);

  final AuthLocalDataSource _dataSource;

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      return Ok(await _dataSource.login(email: email, password: password));
    } on AuthException catch (e) {
      return Err(AuthFailure(e.message));
    }
  }
}
