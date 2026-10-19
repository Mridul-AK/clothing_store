part of 'watchlist_bloc.dart';

enum WatchlistStatus { initial, loading, success, empty, failure }

final class WatchlistState extends Equatable {
  const WatchlistState({
    this.status = WatchlistStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final WatchlistStatus status;
  final List<Product> items;
  final String? errorMessage;

  bool contains(int productId) => items.any((p) => p.id == productId);

  @override
  List<Object?> get props => [status, items, errorMessage];
}
