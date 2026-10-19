import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract interface class AuthLocalDataSource {
  Future<UserModel> login({required String email, required String password});
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl({
    this.latency = const Duration(milliseconds: 800),
    Map<String, ({String password, String name})>? accounts,
  }) : _accounts = accounts ?? _defaultAccounts;

  final Duration latency;
  final Map<String, ({String password, String name})> _accounts;

  static const Map<String, ({String password, String name})> _defaultAccounts =
      {
        AppConstants.demoEmail: (
          password: AppConstants.demoPassword,
          name: AppConstants.demoName,
        ),
      };

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(latency);

    final account = _accounts[email];
    if (account == null || account.password != password) {
      throw const AuthException('Incorrect email or password');
    }
    return UserModel(email: email, displayName: account.name);
  }
}
