import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/bloc/login_bloc.dart';
import 'features/cart/data/datasources/cart_local_data_source.dart';
import 'features/cart/data/repositories/cart_repository_impl.dart';
import 'features/cart/domain/repositories/cart_repository.dart';
import 'features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'features/cart/domain/usecases/clear_cart_usecase.dart';
import 'features/cart/domain/usecases/get_cart_usecase.dart';
import 'features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'features/cart/domain/usecases/update_cart_quantity_usecase.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/payment/data/datasources/payment_local_data_source.dart';
import 'features/payment/data/repositories/payment_repository_impl.dart';
import 'features/payment/domain/repositories/payment_repository.dart';
import 'features/payment/domain/usecases/process_dummy_payment_usecase.dart';
import 'features/payment/presentation/bloc/payment_bloc.dart';
import 'features/products/data/datasources/product_local_data_source.dart';
import 'features/products/data/repositories/product_repository_impl.dart';
import 'features/products/domain/repositories/product_repository.dart';
import 'features/products/domain/usecases/get_products_usecase.dart';
import 'features/products/presentation/bloc/products_bloc.dart';
import 'features/watchlist/data/datasources/watchlist_local_data_source.dart';
import 'features/watchlist/data/repositories/watchlist_repository_impl.dart';
import 'features/watchlist/domain/repositories/watchlist_repository.dart';
import 'features/watchlist/domain/usecases/add_to_watchlist_usecase.dart';
import 'features/watchlist/domain/usecases/get_watchlist_usecase.dart';
import 'features/watchlist/domain/usecases/remove_from_watchlist_usecase.dart';
import 'features/watchlist/presentation/bloc/watchlist_bloc.dart';

final GetIt sl = GetIt.instance;

void initDependencies() {
  sl
    ..registerLazySingleton<AuthLocalDataSource>(AuthLocalDataSourceImpl.new)
    ..registerLazySingleton<ProductLocalDataSource>(
      () => ProductLocalDataSourceImpl(bundle: rootBundle),
    )
    ..registerLazySingleton<WatchlistLocalDataSource>(
      InMemoryWatchlistDataSource.new,
    )
    ..registerLazySingleton<CartLocalDataSource>(InMemoryCartDataSource.new)
    ..registerLazySingleton<PaymentLocalDataSource>(DummyPaymentGateway.new);

  sl
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()))
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(sl()),
    )
    ..registerLazySingleton<WatchlistRepository>(
      () => WatchlistRepositoryImpl(sl()),
    )
    ..registerLazySingleton<CartRepository>(() => CartRepositoryImpl(sl()))
    ..registerLazySingleton<PaymentRepository>(
      () => PaymentRepositoryImpl(sl()),
    );

  sl
    ..registerLazySingleton(() => LoginUseCase(sl()))
    ..registerLazySingleton(() => GetProductsUseCase(sl()))
    ..registerLazySingleton(() => GetWatchlistUseCase(sl()))
    ..registerLazySingleton(() => AddToWatchlistUseCase(sl()))
    ..registerLazySingleton(() => RemoveFromWatchlistUseCase(sl()))
    ..registerLazySingleton(() => GetCartUseCase(sl()))
    ..registerLazySingleton(() => AddToCartUseCase(sl()))
    ..registerLazySingleton(() => RemoveFromCartUseCase(sl()))
    ..registerLazySingleton(() => UpdateCartQuantityUseCase(sl()))
    ..registerLazySingleton(() => ClearCartUseCase(sl()))
    ..registerLazySingleton(
      () => ProcessDummyPaymentUseCase(
        paymentRepository: sl(),
        cartRepository: sl(),
      ),
    );

  sl
    ..registerFactory(() => LoginBloc(login: sl()))
    ..registerFactory(() => ProductsBloc(getProducts: sl()))
    ..registerFactory(
      () => WatchlistBloc(
        getWatchlist: sl(),
        addToWatchlist: sl(),
        removeFromWatchlist: sl(),
      ),
    )
    ..registerFactory(
      () => CartBloc(
        getCart: sl(),
        addToCart: sl(),
        removeFromCart: sl(),
        updateQuantity: sl(),
        clearCart: sl(),
      ),
    )
    ..registerFactory(() => PaymentBloc(processPayment: sl()));
}
