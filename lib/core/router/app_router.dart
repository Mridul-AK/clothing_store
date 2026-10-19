import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/login_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/payment/domain/entities/payment_receipt.dart';
import '../../features/payment/presentation/bloc/payment_bloc.dart';
import '../../features/payment/presentation/pages/checkout_page.dart';
import '../../features/payment/presentation/pages/payment_success_page.dart';
import '../../injection_container.dart';

abstract final class AppRoutes {
  static const String login = '/';
  static const String home = '/home';
  static const String checkout = '/checkout';
  static const String paymentSuccess = '/payment-success';
}

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      AppRoutes.login => BlocProvider(
        create: (_) => sl<LoginBloc>(),
        child: const LoginPage(),
      ),
      AppRoutes.home => const HomePage(),
      AppRoutes.checkout => BlocProvider(
        create: (_) => sl<PaymentBloc>(),
        child: const CheckoutPage(),
      ),
      AppRoutes.paymentSuccess => switch (settings.arguments) {
        final PaymentReceipt receipt => PaymentSuccessPage(receipt: receipt),
        _ => _NotFoundPage(name: settings.name),
      },
      _ => _NotFoundPage(name: settings.name),
    };

    return MaterialPageRoute<void>(settings: settings, builder: (_) => page);
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage({this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('Page not found: ${name ?? 'unknown'}')),
    );
  }
}
