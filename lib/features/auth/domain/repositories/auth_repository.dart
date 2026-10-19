import '../../../../core/error/result.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  Future<Result<User>> login({required String email, required String password});
}
