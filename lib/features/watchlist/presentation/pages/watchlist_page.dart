import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/state_views.dart';
import '../../../products/presentation/widgets/product_grid.dart';
import '../bloc/watchlist_bloc.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key, this.onBrowse});

  final VoidCallback? onBrowse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      body: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) {
          return switch (state.status) {
            WatchlistStatus.initial ||
            WatchlistStatus.loading => const LoadingView(),
            WatchlistStatus.failure when state.items.isEmpty => ErrorStateView(
              message: state.errorMessage ?? 'Could not load your watchlist.',
              onRetry: () =>
                  context.read<WatchlistBloc>().add(const LoadWatchlist()),
            ),
            WatchlistStatus.empty => EmptyStateView(
              icon: Icons.favorite_border,
              title: 'Your watchlist is empty',
              message: 'Tap the heart on any product to save it here.',
              actionLabel: onBrowse == null ? null : 'Browse products',
              onAction: onBrowse,
            ),
            WatchlistStatus.success ||
            WatchlistStatus.failure => ProductGrid(products: state.items),
          };
        },
      ),
    );
  }
}
