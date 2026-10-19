import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/total_bar.dart';
import '../bloc/cart_bloc.dart';
import '../widgets/cart_item_tile.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key, this.onBrowse});

  final VoidCallback? onBrowse;

  Future<void> _confirmClear(BuildContext context) async {
    final bloc = context.read<CartBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('All items will be removed from your cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) bloc.add(const ClearCart());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final cart = state.cart;

        return Scaffold(
          appBar: AppBar(
            title: Text(cart.isEmpty ? 'Cart' : 'Cart (${cart.totalItems})'),
            actions: [
              if (!cart.isEmpty)
                IconButton(
                  tooltip: 'Clear cart',
                  onPressed: () => _confirmClear(context),
                  icon: const Icon(Icons.remove_shopping_cart_outlined),
                ),
            ],
          ),
          body: switch (state.status) {
            CartStatus.initial || CartStatus.loading => const LoadingView(),
            CartStatus.failure => ErrorStateView(
              message: state.errorMessage ?? 'Could not load your cart.',
              onRetry: () => context.read<CartBloc>().add(const LoadCart()),
            ),
            CartStatus.empty => EmptyStateView(
              icon: Icons.shopping_bag_outlined,
              title: 'Your cart is empty',
              message: 'Add a few favourites and they will show up here.',
              actionLabel: onBrowse == null ? null : 'Start shopping',
              onAction: onBrowse,
            ),
            CartStatus.success => ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: cart.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                final bloc = context.read<CartBloc>();
                final id = item.product.id;
                return CartItemTile(
                  key: ValueKey(id),
                  item: item,
                  onIncrement: () => bloc.add(IncreaseQuantity(id)),
                  onDecrement: () => bloc.add(DecreaseQuantity(id)),
                  onRemove: () => bloc.add(RemoveFromCart(id)),
                );
              },
            ),
          },
          bottomNavigationBar: state.status == CartStatus.success
              ? TotalBar(
                  label:
                      'Total · ${cart.totalItems} item${cart.totalItems == 1 ? '' : 's'}',
                  amount: cart.totalAmount,
                  actionLabel: 'Checkout',
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.checkout),
                )
              : null,
        );
      },
    );
  }
}
