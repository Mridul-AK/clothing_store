import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/products/presentation/bloc/products_bloc.dart';
import 'features/watchlist/presentation/bloc/watchlist_bloc.dart';
import 'injection_container.dart';

class ClothingStoreApp extends StatelessWidget {
  const ClothingStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ProductsBloc>()..add(const LoadProducts()),
        ),
        BlocProvider(
          create: (_) => sl<WatchlistBloc>()..add(const LoadWatchlist()),
        ),
        BlocProvider(create: (_) => sl<CartBloc>()..add(const LoadCart())),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        initialRoute: AppRoutes.login,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
