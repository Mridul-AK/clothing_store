import 'package:clothing_store/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:clothing_store/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:clothing_store/features/auth/domain/usecases/login_usecase.dart';
import 'package:clothing_store/features/auth/presentation/bloc/login_bloc.dart';
import 'package:clothing_store/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login button is enabled only when both fields are valid', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => LoginBloc(
            login: LoginUseCase(
              AuthRepositoryImpl(
                AuthLocalDataSourceImpl(latency: Duration.zero),
              ),
            ),
          ),
          child: const LoginPage(),
        ),
      ),
    );

    FilledButton button() =>
        tester.widget<FilledButton>(find.byKey(const Key('login_submit')));

    expect(button().onPressed, isNull);

    await tester.enterText(find.byKey(const Key('login_email')), 'not-email');
    await tester.pump();
    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(button().onPressed, isNull);

    await tester.enterText(find.byKey(const Key('login_email')), 'a@b.com');
    await tester.enterText(find.byKey(const Key('login_password')), 'secret1');
    await tester.pump();
    expect(find.text('Enter a valid email address'), findsNothing);
    expect(button().onPressed, isNotNull);
  });
}
