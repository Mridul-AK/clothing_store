part of 'watchlist_bloc.dart';

sealed class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

final class LoadWatchlist extends WatchlistEvent {
  const LoadWatchlist();
}

final class AddToWatchlist extends WatchlistEvent {
  const AddToWatchlist(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

final class RemoveFromWatchlist extends WatchlistEvent {
  const RemoveFromWatchlist(this.productId);

  final int productId;

  @override
  List<Object?> get props => [productId];
}

final class ToggleWatchlist extends WatchlistEvent {
  const ToggleWatchlist(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}
