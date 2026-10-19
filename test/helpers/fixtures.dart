import 'package:clothing_store/features/cart/domain/entities/cart.dart';
import 'package:clothing_store/features/cart/domain/entities/cart_item.dart';
import 'package:clothing_store/features/products/domain/entities/product.dart';

const tShirt = Product(
  id: 1,
  name: 'Tee',
  subtitle: 'Cotton tee',
  price: 19.99,
  imageUrl: 'https://example.com/tee.png',
  category: 'Men',
);

const jacket = Product(
  id: 2,
  name: 'Jacket',
  subtitle: 'Rain jacket',
  price: 49.50,
  imageUrl: 'https://example.com/jacket.png',
  category: 'Women',
);

/// Prices chosen so a naive double sum drifts (0.1 + 0.2 != 0.3).
const dime = Product(
  id: 3,
  name: 'Sticker',
  subtitle: 'Tiny',
  price: 0.10,
  imageUrl: 'https://example.com/a.png',
  category: 'Accessories',
);

const twentyCents = Product(
  id: 4,
  name: 'Badge',
  subtitle: 'Tiny',
  price: 0.20,
  imageUrl: 'https://example.com/b.png',
  category: 'Accessories',
);

Cart cartOf(Map<Product, int> lines) => Cart(
  items: [
    for (final entry in lines.entries)
      CartItem(product: entry.key, quantity: entry.value),
  ],
);
