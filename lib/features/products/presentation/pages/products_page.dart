import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/state_views.dart';
import '../bloc/products_bloc.dart';
import '../widgets/product_grid.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<ProductsBloc>()..add(const LoadProducts());
    await bloc.stream.firstWhere((state) => state is! ProductsLoading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          return switch (state) {
            ProductsInitial() || ProductsLoading() => const LoadingView(
              message: 'Loading products…',
            ),
            ProductsLoaded(:final products) => RefreshIndicator(
              onRefresh: () => _refresh(context),
              child: ProductGrid(products: products),
            ),
            ProductsEmpty() => EmptyStateView(
              icon: Icons.inventory_2_outlined,
              title: 'No products yet',
              message: 'The catalogue is empty. Check back soon.',
              actionLabel: 'Reload',
              onAction: () =>
                  context.read<ProductsBloc>().add(const LoadProducts()),
            ),
            ProductsError(:final message) => ErrorStateView(
              message: message,
              onRetry: () =>
                  context.read<ProductsBloc>().add(const LoadProducts()),
            ),
          };
        },
      ),
    );
  }
}
