import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products_usecase.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc({required GetProductsUseCase getProducts})
    : _getProducts = getProducts,
      super(const ProductsInitial()) {
    on<LoadProducts>(_onLoad, transformer: restartable());
  }

  final GetProductsUseCase _getProducts;

  Future<void> _onLoad(LoadProducts event, Emitter<ProductsState> emit) async {
    emit(const ProductsLoading());

    final result = await _getProducts(const NoParams());

    emit(
      result.fold(
        (failure) => ProductsError(failure.message),
        (products) =>
            products.isEmpty ? const ProductsEmpty() : ProductsLoaded(products),
      ),
    );
  }
}
