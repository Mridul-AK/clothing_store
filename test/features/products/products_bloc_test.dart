import 'package:bloc_test/bloc_test.dart';
import 'package:clothing_store/core/error/failures.dart';
import 'package:clothing_store/core/error/result.dart';
import 'package:clothing_store/features/products/domain/entities/product.dart';
import 'package:clothing_store/features/products/domain/repositories/product_repository.dart';
import 'package:clothing_store/features/products/domain/usecases/get_products_usecase.dart';
import 'package:clothing_store/features/products/presentation/bloc/products_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';

class _MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late _MockProductRepository repository;

  setUp(() => repository = _MockProductRepository());

  ProductsBloc buildBloc() =>
      ProductsBloc(getProducts: GetProductsUseCase(repository));

  blocTest<ProductsBloc, ProductsState>(
    'emits [loading, loaded] when products are available',
    setUp: () => when(
      () => repository.getProducts(),
    ).thenAnswer((_) async => const Ok([tShirt, jacket])),
    build: buildBloc,
    act: (bloc) => bloc.add(const LoadProducts()),
    expect: () => const [
      ProductsLoading(),
      ProductsLoaded([tShirt, jacket]),
    ],
  );

  blocTest<ProductsBloc, ProductsState>(
    'emits [loading, empty] when the catalogue has no products',
    setUp: () => when(
      () => repository.getProducts(),
    ).thenAnswer((_) async => const Ok(<Product>[])),
    build: buildBloc,
    act: (bloc) => bloc.add(const LoadProducts()),
    expect: () => const [ProductsLoading(), ProductsEmpty()],
  );

  blocTest<ProductsBloc, ProductsState>(
    'emits [loading, error] when loading fails',
    setUp: () => when(() => repository.getProducts()).thenAnswer(
      (_) async =>
          const Err(DataFailure('The product catalogue is malformed.')),
    ),
    build: buildBloc,
    act: (bloc) => bloc.add(const LoadProducts()),
    expect: () => const [
      ProductsLoading(),
      ProductsError('The product catalogue is malformed.'),
    ],
  );
}
