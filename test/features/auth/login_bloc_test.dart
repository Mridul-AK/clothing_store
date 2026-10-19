import 'package:bloc_test/bloc_test.dart';
import 'package:clothing_store/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:clothing_store/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:clothing_store/features/auth/domain/usecases/login_usecase.dart';
import 'package:clothing_store/features/auth/presentation/bloc/login_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  LoginBloc buildBloc() => LoginBloc(
    login: LoginUseCase(
      AuthRepositoryImpl(
        AuthLocalDataSourceImpl(
          latency: Duration.zero,
          accounts: {'demo@shop.com': (password: 'Demo@123', name: 'Demo')},
        ),
      ),
    ),
  );

  test('login button starts disabled', () {
    expect(buildBloc().state.canSubmit, isFalse);
  });

  blocTest<LoginBloc, LoginState>(
    'enables submit only once both fields are valid',
    build: buildBloc,
    act: (bloc) => bloc
      ..add(const LoginEmailChanged('demo@'))
      ..add(const LoginEmailChanged('demo@shop.com'))
      ..add(const LoginPasswordChanged('Demo@123')),
    verify: (bloc) {
      expect(bloc.state.emailError, isNull);
      expect(bloc.state.passwordError, isNull);
      expect(bloc.state.canSubmit, isTrue);
    },
    expect: () => [
      isA<LoginState>()
          .having((s) => s.emailError, 'emailError', isNotNull)
          .having((s) => s.canSubmit, 'canSubmit', isFalse),
      isA<LoginState>()
          .having((s) => s.emailError, 'emailError', isNull)
          .having((s) => s.canSubmit, 'canSubmit', isFalse),
      isA<LoginState>().having((s) => s.canSubmit, 'canSubmit', isTrue),
    ],
  );

  blocTest<LoginBloc, LoginState>(
    'submitting valid credentials ends in success',
    build: buildBloc,
    seed: () => const LoginState(email: 'demo@shop.com', password: 'Demo@123'),
    act: (bloc) => bloc.add(const LoginSubmitted()),
    expect: () => [
      isA<LoginState>().having(
        (s) => s.status,
        'status',
        LoginStatus.submitting,
      ),
      isA<LoginState>()
          .having((s) => s.status, 'status', LoginStatus.success)
          .having((s) => s.user?.email, 'user', 'demo@shop.com'),
    ],
  );

  blocTest<LoginBloc, LoginState>(
    'wrong password ends in failure with an error message',
    build: buildBloc,
    seed: () => const LoginState(email: 'demo@shop.com', password: 'Wrong@123'),
    act: (bloc) => bloc.add(const LoginSubmitted()),
    expect: () => [
      isA<LoginState>().having(
        (s) => s.status,
        'status',
        LoginStatus.submitting,
      ),
      isA<LoginState>()
          .having((s) => s.status, 'status', LoginStatus.failure)
          .having((s) => s.errorMessage, 'errorMessage', isNotNull),
    ],
  );
}
