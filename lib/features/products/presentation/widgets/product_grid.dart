import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../watchlist/presentation/bloc/watchlist_bloc.dart';
import '../../domain/entities/product.dart';
import 'product_card.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final watchlist = context.watch<WatchlistBloc>().state;
    final cart = context.select((CartBloc bloc) => bloc.state.cart);

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisExtent: 340,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          isFavourite: watchlist.contains(product.id),
          cartQuantity: cart.quantityOf(product.id),
          onFavouriteToggle: () =>
              context.read<WatchlistBloc>().add(ToggleWatchlist(product)),
          onAddToCart: () => context.read<CartBloc>().add(AddToCart(product)),
        );
      },
    );
  }
}
