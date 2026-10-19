import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/usecases/add_to_watchlist_usecase.dart';
import '../../domain/usecases/get_watchlist_usecase.dart';
import '../../domain/usecases/remove_from_watchlist_usecase.dart';

part 'watchlist_event.dart';
part 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  WatchlistBloc({
    required GetWatchlistUseCase getWatchlist,
    required AddToWatchlistUseCase addToWatchlist,
    required RemoveFromWatchlistUseCase removeFromWatchlist,
  }) : _getWatchlist = getWatchlist,
       _addToWatchlist = addToWatchlist,
       _removeFromWatchlist = removeFromWatchlist,
       super(const WatchlistState()) {
    on<WatchlistEvent>(_onEvent, transformer: sequential());
  }

  final GetWatchlistUseCase _getWatchlist;
  final AddToWatchlistUseCase _addToWatchlist;
  final RemoveFromWatchlistUseCase _removeFromWatchlist;

  Future<void> _onEvent(
    WatchlistEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    switch (event) {
      case LoadWatchlist():
        if (state.status == WatchlistStatus.initial) {
          emit(const WatchlistState(status: WatchlistStatus.loading));
        }
        _emitResult(await _getWatchlist(const NoParams()), emit);
      case AddToWatchlist(:final product):
        _emitResult(await _addToWatchlist(product), emit);
      case RemoveFromWatchlist(:final productId):
        _emitResult(await _removeFromWatchlist(productId), emit);
      case ToggleWatchlist(:final product):
        final result = state.contains(product.id)
            ? await _removeFromWatchlist(product.id)
            : await _addToWatchlist(product);
        _emitResult(result, emit);
    }
  }

  void _emitResult(Result<List<Product>> result, Emitter<WatchlistState> emit) {
    emit(
      result.fold(
        (failure) => WatchlistState(
          status: WatchlistStatus.failure,
          items: state.items,
          errorMessage: failure.message,
        ),
        (items) => WatchlistState(
          status: items.isEmpty
              ? WatchlistStatus.empty
              : WatchlistStatus.success,
          items: items,
        ),
      ),
    );
  }
}
