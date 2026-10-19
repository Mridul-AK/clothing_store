import 'package:clothing_store/core/error/failures.dart';
import 'package:clothing_store/core/error/result.dart';
import 'package:clothing_store/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:clothing_store/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:clothing_store/features/auth/domain/entities/user.dart';
import 'package:clothing_store/features/auth/domain/repositories/auth_repository.dart';
import 'package:clothing_store/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('LoginUseCase (mocked repository)', () {
    late _MockAuthRepository repository;
    late LoginUseCase login;

    setUp(() {
      repository = _MockAuthRepository();
      login = LoginUseCase(repository);
    });

    test('returns ValidationFailure and never calls the repository '
        'when input is invalid', () async {
      final result = await login(
        const LoginParams(email: 'not-an-email', password: 'secret123'),
      );

      expect(
        result,
        const Err<User>(ValidationFailure('Enter a valid email address')),
      );
      verifyNever(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test('normalises the email before authenticating', () async {
      const user = User(email: 'demo@shop.com', displayName: 'Demo');
      when(
        () => repository.login(email: 'demo@shop.com', password: 'secret123'),
      ).thenAnswer((_) async => const Ok(user));

      final result = await login(
        const LoginParams(email: '  Demo@Shop.com ', password: 'secret123'),
      );

      expect(result, const Ok(user));
    });
  });

  group('LoginUseCase (dummy credentials)', () {
    final login = LoginUseCase(
      AuthRepositoryImpl(
        AuthLocalDataSourceImpl(
          latency: Duration.zero,
          accounts: {'demo@shop.com': (password: 'Demo@123', name: 'Demo')},
        ),
      ),
    );

    test('succeeds with the predefined credentials', () async {
      final result = await login(
        const LoginParams(email: 'demo@shop.com', password: 'Demo@123'),
      );

      expect(result.fold((_) => null, (u) => u.email), 'demo@shop.com');
    });

    test('fails with AuthFailure for a wrong password', () async {
      final result = await login(
        const LoginParams(email: 'demo@shop.com', password: 'wrong-pass'),
      );

      expect(result.fold((f) => f, (_) => null), isA<AuthFailure>());
    });

    test('fails with AuthFailure for an unknown account', () async {
      final result = await login(
        const LoginParams(email: 'nobody@shop.com', password: 'Demo@123'),
      );

      expect(result.fold((f) => f, (_) => null), isA<AuthFailure>());
    });
  });
}
