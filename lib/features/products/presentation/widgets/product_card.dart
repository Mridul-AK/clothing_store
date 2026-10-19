import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/product_image.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.isFavourite,
    required this.cartQuantity,
    required this.onFavouriteToggle,
    required this.onAddToCart,
  });

  final Product product;
  final bool isFavourite;
  final int cartQuantity;
  final VoidCallback onFavouriteToggle;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ProductImage(url: product.imageUrl),
                Positioned(
                  top: 6,
                  right: 6,
                  child: FavouriteButton(
                    isFavourite: isFavourite,
                    onPressed: onFavouriteToggle,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  height: 34,
                  child: Text(
                    product.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatPrice(product.price),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: FilledButton.tonalIcon(
              onPressed: onAddToCart,
              icon: const Icon(Icons.add_shopping_cart, size: 18),
              label: Text(
                cartQuantity == 0
                    ? 'Add to cart'
                    : 'Add · $cartQuantity in cart',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FavouriteButton extends StatelessWidget {
  const FavouriteButton({
    super.key,
    required this.isFavourite,
    required this.onPressed,
  });

  final bool isFavourite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: isFavourite ? 'Remove from watchlist' : 'Add to watchlist',
      style: IconButton.styleFrom(
        backgroundColor: scheme.surface.withValues(alpha: 0.9),
      ),
      onPressed: onPressed,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          isFavourite ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(isFavourite),
          color: isFavourite ? Colors.redAccent : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
