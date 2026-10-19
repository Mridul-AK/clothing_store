import 'package:bloc_test/bloc_test.dart';
import 'package:clothing_store/features/watchlist/data/datasources/watchlist_local_data_source.dart';
import 'package:clothing_store/features/watchlist/data/repositories/watchlist_repository_impl.dart';
import 'package:clothing_store/features/watchlist/domain/usecases/add_to_watchlist_usecase.dart';
import 'package:clothing_store/features/watchlist/domain/usecases/get_watchlist_usecase.dart';
import 'package:clothing_store/features/watchlist/domain/usecases/remove_from_watchlist_usecase.dart';
import 'package:clothing_store/features/watchlist/presentation/bloc/watchlist_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

/// Real use cases + real in-memory repository: exercises the full stack
/// below the BLoC, not just mocks.
WatchlistBloc _buildBloc() {
  final repository = WatchlistRepositoryImpl(InMemoryWatchlistDataSource());
  return WatchlistBloc(
    getWatchlist: GetWatchlistUseCase(repository),
    addToWatchlist: AddToWatchlistUseCase(repository),
    removeFromWatchlist: RemoveFromWatchlistUseCase(repository),
  );
}

void main() {
  blocTest<WatchlistBloc, WatchlistState>(
    'starts loading, then reports an empty watchlist',
    build: _buildBloc,
    act: (bloc) => bloc.add(const LoadWatchlist()),
    expect: () => const [
      WatchlistState(status: WatchlistStatus.loading),
      WatchlistState(status: WatchlistStatus.empty),
    ],
  );

  blocTest<WatchlistBloc, WatchlistState>(
    'adds products in order and ignores duplicates',
    build: _buildBloc,
    act: (bloc) => bloc
      ..add(const AddToWatchlist(tShirt))
      ..add(const AddToWatchlist(jacket))
      ..add(const AddToWatchlist(tShirt)),
    expect: () => const [
      WatchlistState(status: WatchlistStatus.success, items: [tShirt]),
      WatchlistState(status: WatchlistStatus.success, items: [tShirt, jacket]),
      // Duplicate add produces an identical state, which bloc does not re-emit.
    ],
    verify: (bloc) => expect(bloc.state.contains(tShirt.id), isTrue),
  );

  blocTest<WatchlistBloc, WatchlistState>(
    'removing the last product leaves an empty watchlist',
    build: _buildBloc,
    act: (bloc) => bloc
      ..add(const AddToWatchlist(tShirt))
      ..add(RemoveFromWatchlist(tShirt.id)),
    expect: () => const [
      WatchlistState(status: WatchlistStatus.success, items: [tShirt]),
      WatchlistState(status: WatchlistStatus.empty),
    ],
    verify: (bloc) => expect(bloc.state.contains(tShirt.id), isFalse),
  );

  blocTest<WatchlistBloc, WatchlistState>(
    'toggle adds when absent and removes when present',
    build: _buildBloc,
    act: (bloc) => bloc
      ..add(const ToggleWatchlist(jacket))
      ..add(const ToggleWatchlist(jacket)),
    expect: () => const [
      WatchlistState(status: WatchlistStatus.success, items: [jacket]),
      WatchlistState(status: WatchlistStatus.empty),
    ],
  );
}
